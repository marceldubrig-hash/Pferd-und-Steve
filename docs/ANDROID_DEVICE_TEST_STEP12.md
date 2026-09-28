# Schritt 12 — Android-Gerätetest

Status: **vorbereitet / physischer Test ausstehend**

Zielgerät:
- Samsung Galaxy Z Fold7
- Android 16

Getesteter Build:
- Datei: `Pferd-und-Steve-step11-debug.apk`
- SHA-256: `782dfed3cb22d7fd38ad52f9402cacacc75a60de86b4be08465266097c4be4de`
- Herkunft: erfolgreicher GitHub-Actions-Run `36354264467`
- Artifact: `Pferd-und-Steve-step11-final-apk`
- Artifact-ID: `10942949469`

## Testreihenfolge

Der Gerätetest verändert zunächst **keinen Runtime-Code**. Erst Beobachtungen sammeln, dann einzeln beheben.

1. App starten und prüfen, ob die Farm korrekt lädt.
2. Pferd in FAR-, MID- und NEAR-Bereich bewegen.
3. In jeder Distanz nach rechts und links laufen.
4. Prüfen:
   - Pferd bleibt sauber am Boden verankert.
   - Größe/Perspektive wirkt korrekt.
   - Ganzes Rig spiegelt gemeinsam.
   - Walk bleibt lesbar und zerfällt nicht.
   - Keine sichtbaren Segmentlücken an Beinen/Körper.
   - Kopf und Unterkiefer sitzen korrekt.
   - Schweif sitzt korrekt.
   - Touch/Drag reagiert sauber.
   - Keine auffälligen FPS-Einbrüche oder Hänger.
5. Besonders extreme Kameranähe testen.
6. Richtungswechsel mehrfach direkt hintereinander testen.

## Rückmeldung erfassen

Für jeden Fehler möglichst:
- Screenshot oder kurzes Video
- FAR / MID / NEAR
- LEFT / RIGHT
- Was genau sichtbar falsch ist
- Ob der Fehler dauerhaft oder nur während Bewegung auftritt

## Stop-Regel

Nach dem Gerätetest keine State-Machine, kein bewegungsabhängiges Walk, kein sprechabhängiger Jaw, kein Steve, kein Sound und kein weiteres Gameplay beginnen, bevor die Step-12-Beobachtungen dokumentiert und einzeln abgearbeitet wurden.


## 12A — Kopf höher gesetzt

Umgesetzt nach dem echten Android-Gerätetest.

- `HeadPivot.y` wurde von `-194.253` auf `-236.253` angehoben (42 Rig-Pixel).
- Unterkiefer/Jaw bleibt Kind von `HeadPivot` und wird deshalb ohne eigene Assetänderung sauber mitgeführt.
- Wichtig: nicht nur der statische Node-Transform wurde geändert. Auch der `RESET`-Key sowie alle `HeadPivot:position`-Keys in `walk_test` wurden um exakt denselben Betrag angehoben, damit Autoplay den Fix nicht zurücksetzt.
- Farm-Perspektive, Bodenanker, Ganzrig-Flip und Assetdateien blieben unverändert.
- Runtime-Commit: `378f8a73a89a419e0d918f139f37ba2b5735309f` (`Raise horse head position for farm runtime`).

Nächster isolierter Fix: 12B — sichtbaren Hals/Mähnen-/Segmentbereich hinter dem Kopf durch vorhandene Rig-Transforms/Layering sauber verdecken.


## 12B — Kopf-/Halsüberdeckung bereinigt

- Der komplette `HeadPivot` (inklusive Jaw als Kind) wurde zusätzlich 18 Rig-Pixel nach hinten/links versetzt: `x 321.171 → 303.171`.
- Dieselbe X-Korrektur wurde in RESET und allen `HeadPivot:position`-Keys des Walks übernommen, damit die Animation die Überdeckung nicht wieder aufreißt.
- `HeadPivot.z_index` wurde von `10` auf `12` angehoben; Head/Jaw bleiben damit eindeutig vor dem Body-/Halsstumpf.
- Keine Textur, kein Asset und keine Farm-Geometrie wurde verändert.
- Runtime-Commit: `1b9cd86e118c20ecac2b70a6d8439133dfe15f07` (`Fix head and mane overlap behind horse head`).

Nächster isolierter Fix: 12C — anatomisch falsch gerichtetes Hinterbein korrigieren.


## 12C — Hinterbeinrichtung korrigiert

- Der Gerätetest hat die bisher nur statisch validierte Ausrichtung von `HindNear` überstimmt: die Kette wirkte in der echten Farm anatomisch verkehrt herum.
- Korrektur erfolgt ausschließlich als Root-Transform der vollständigen bestehenden Kette: `HindNear.scale = (-0.5, 0.5)` statt `(0.5, 0.5)`.
- Keine Segmenttextur wurde ersetzt, neu gerendert oder einzeln gespiegelt.
- Weil eine negative X-Skalierung die sichtbare Drehrichtung invertiert, wurden die Vorzeichen der drei bestehenden `HindNear`-Walk-Tracks (Root, LowerPivot, HoofPivot) passend invertiert. So bleibt die beabsichtigte Gelenkbeugung beim Laufen erhalten.
- Runtime-Commit: `bd81055911cb30fd86b2eb079502a0126b4de302` (`Correct reversed hind leg orientation`).

Nächster isolierter Fix: 12D — äußerstes `HindFar` näher unter die Hinterhand setzen.


## 12D — Äußeres Hinterbein näher an den Körper gesetzt

- `HindFar.x` wurde von `-262` auf `-330` verschoben.
- Y-Position, Scale, Upper/Lower/Hoof-Pivots und sämtliche Quelltexturen blieben unverändert.
- Dadurch rückt das zuvor optisch isolierte äußerste Hinterbein um 68 Rig-Pixel unter die Hinterhand, ohne Körper, Bodenanker oder Perspektive zu verschieben.
- Runtime-Commit: `26ba13c40a27b603f0370f82f5a77759365a6cad` (`Reposition outer hind leg closer to body`).

Nächster isolierter Fix: 12E — Z-Reihenfolge von Schweif/Body/HindFar/HindNear eindeutig machen.


## 12E — Hinterbein-Layering poliert

- Die bisher mehrdeutige Tiefenreihenfolge wurde deterministisch gemacht: `TailPivot z=-2`, `HindFar z=-1`, Body auf Basis-Z `0`, `HindNear z=1`, Head weiterhin deutlich darüber auf `z=12`.
- Damit kann das hintere Bein nicht mehr in derselben Z-Ebene mit dem Schweif um die Zeichenreihenfolge konkurrieren.
- Alle Attachment-Positionen aus 12C/12D bleiben erhalten; keine Texturänderung.
- Runtime-Commit: `ccd15bfa5d73af62003e90f71fa42d4215c2146b` (`Polish hind leg layering and body attachment`).

Nächster isolierter Fix: 12F — bestehende Walk-Keys kräftiger und besser lesbar machen.


## 12F — Walk deutlich verstärkt

Die bestehende `walk_test`-Animation wurde beibehalten, aber ihre Beinbewegung deutlich lesbarer gemacht.

- Root-Schwung der Beine liegt nun grob bei 9–14° statt zuvor etwa 4–6°.
- LowerPivot-Beugung liegt nun grob bei 12–18° statt zuvor etwa 5–8°.
- HoofPivot-Ausgleich liegt nun grob bei 6–9° statt zuvor etwa 2–4°.
- Die vier Beinketten wurden auf klar getrennte Viertelphasen des bestehenden 1,2-s-Zyklus verteilt. Damit arbeiten sie nicht mehr nahezu gleichzeitig, sondern lesen sich deutlich eher als 4-Takt-Walk.
- Body-/Head-/Tail-Bob blieb bewusst klein; die bestehende Positionsbewegung wurde nicht hochskaliert.
- Die reale Gangreferenz wurde nur als Rhythmus-/Phasenleitlinie genutzt; es wurde keine neue Gait-State-Machine gebaut.
- Runtime-Commit: `c2b24d34855bad9995011f74153f5ec8d1051a76` (`Increase horse walk animation amplitude`).

Nächster isolierter Fix: 12G — Walk-Frequenz und leichte Zusatzamplitude an die reale Drag-/Bewegungsgeschwindigkeit koppeln.


## 12G — Walk an Bewegungsgeschwindigkeit gekoppelt

- Es wurde bewusst **keine** Walk/Trot/Canter-State-Machine gebaut.
- `InputEventScreenDrag.velocity` bzw. Mausgeschwindigkeit steuert nun direkt den bestehenden `WalkAnimationPlayer`.
- Playback-Speed wird weich zwischen `0.72×` und `1.60×` skaliert.
- Zusätzlich werden die bereits vorhandenen Walk-Keywerte nicht-destruktiv aus einer beim Start gecachten Basis zwischen `0.86×` und `1.20×` amplitudenskaliert.
- Rotationskeys werden um 0 skaliert; Body/Head/Tail-Positionskeys werden relativ zu ihrem jeweiligen Ruhewert skaliert, damit kein Drift entsteht.
- Ein einzelner Tap ohne Drag-Velocity wird absichtlich als ruhige Bewegung behandelt statt als künstlicher Hochgeschwindigkeitssprung.
- Runtime-Commit: `f3eb8ce362bf413b0d22c979844fbee39473f4ca` (`Scale walk cycle with movement speed`).

Damit sind 12A–12G im Runtime-Code umgesetzt. Als nächstes folgt die gemeinsame Godot-4.3-/Android-Debug-Validierung und ein neuer Step-12-Testbuild.


## Step-12 automatisierte Abschlussvalidierung

Status: **erfolgreich**.

- Validierungsbasis / Build-Source: `d10b76b235f8a81cb60d163a8e34f1be7e8af0e0`.
- GitHub-Actions-Run: `36361667754`.
- Asset-Integrität: **success**.
- Step-12-Source-Invarianten: **success**.
- Godot 4.3 Headless Editor/Parse: **success**.
- Echte `main.tscn` headless gestartet: **success**.
- Android Debug Export: **success**.
- APK: `Pferd-und-Steve-step12-debug.apk`.
- Artifact: `Pferd-und-Steve-step12-final-apk`.
- Artifact-ID: `10945053792`.
- APK SHA-256: `9bc3bb2972905b0e780afa5ad6808517486d0817140e9b4a05b7d541cd9ef648`.
- Automatischer Nachweis-Commit: `ddef8d00606dc4b18f70b857726c429728631c61` (`Record Step 12 Android validation`).

### Stand für den physischen Retest

Alle angeforderten Runtime-Fixes 12A–12G sind implementiert und technisch exportfähig. **Der neue physische Fold-Gerätetest ist noch nicht durchgeführt**; dieser kann erst nach Installation der neuen APK durch den Nutzer bewertet werden. Daher werden Kopf-/Layering-/Anatomie-/Walk-Qualität auf dem echten Gerät noch nicht als visuell bestätigt behauptet.

Beim Retest gezielt prüfen:
- Kopfposition und Hals-/Mähnenübergang
- `HindNear`-Anatomie in Stand und Bewegung
- `HindFar`-Anschluss unter der Hinterhand
- Schweif / HindFar / Body / HindNear Layering
- stärkere Walk-Lesbarkeit
- langsames / mittleres / schnelles Drag-Tempo
- Richtungswechsel LEFT/RIGHT
- FAR / MID / NEAR und extreme Kameranähe
- Huf-/Bodenanker, Segmentlücken, Perspektivscale, Touch/Drag und Performance

### Bekannte Restarbeit

Keine bekannte automatisierte Parse-/Runtime-/Exportblockade. Offener Punkt ist ausschließlich die visuelle/gefühlte Abnahme auf dem Samsung Galaxy Z Fold7. Falls dort noch etwas auffällt, wird nur der konkrete Step-12-Restfehler behoben; noch kein Steve-, Sound-, Jaw-Sprach- oder vollständiges Gait-System beginnen.


## WICHTIG — erster Step-12-Fixversuch auf echtem Gerät VERWORFEN

Der Build aus Run `36361667754` / APK-SHA `9bc3bb2972905b0e780afa5ad6808517486d0817140e9b4a05b7d541cd9ef648` ist **NICHT mehr gültiger Runtime-Canon**.

Der anschließende echte Android-Test zeigte klare Regressionen:

- beide Hinterbeine wirkten anatomisch falsch herum
- zuvor bereits sauber getestete Hof-/Hindernisbegrenzungen verhielten sich sichtbar wieder falsch
- die in 12C–12G vorgenommenen Änderungen waren damit nicht akzeptabel

### Ursache / Korrektur

Der Fehler entstand dadurch, dass der Gerätetest-Befund zu aggressiv interpretiert wurde:

- `HindNear` wurde als komplette Kette gespiegelt
- HindFar wurde verschoben
- der zuvor validierte Walk wurde stark umgebaut
- `main.gd` bekam zusätzlich neue geschwindigkeitsabhängige Bewegungslogik

Das war entgegen der Vorgabe zu invasiv. Diese Änderungen wurden vollständig verworfen.

### Recovery-Canon

1. `scripts/main.gd` wurde **exakt auf den validierten Step-11-Stand** aus Commit `e8771b39dd0f7619a882e78fd6f657d48f46de6b` zurückgesetzt.
   - Recovery-Commit: `c8d10c7a8c84562275b2ec029b8fe281ec5116d0`
   - Blob-SHA wieder exakt: `a32408d507f0ee1c928c766f214666bedad65175`
   - Damit sind Drag, Perspektive und alle obstacle-aware Hofgrenzen wieder exakt Step 11.

2. `scenes/horse_cutout_rig.tscn` wurde bezüglich **beider Hinterbeine, Layering und komplettem Walk** exakt auf Step 11 zurückgesetzt.
   - Recovery-Commit: `7f3b243753080d8ebc26e9c5accf12820bb6793d`
   - Erhalten bleiben ausschließlich die isolierten Kopfkorrekturen 12A/12B:
     - HeadPivot `(303.171, -236.253)`
     - Head-Z `12`
     - entsprechende Head-RESET-/Walk-Positionskeys
   - Aktueller Scene-Blob-SHA: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

### Nicht mehr gültig

Die Runtime-Änderungen aus folgenden Commits dürfen **nicht** erneut als Zielzustand übernommen werden:

- `bd81055911cb30fd86b2eb079502a0126b4de302` — HindNear-Mirror
- `26ba13c40a27b603f0370f82f5a77759365a6cad` — HindFar-Verschiebung
- `ccd15bfa5d73af62003e90f71fa42d4215c2146b` — Step-12-Layeränderung
- `c2b24d34855bad9995011f74153f5ec8d1051a76` — verstärkter Walk
- `f3eb8ce362bf413b0d22c979844fbee39473f4ca` — Geschwindigkeitskopplung

Der nächste Testbuild ist daher bewusst ein **Recovery-Build: Step-11 Bewegung/Beine + Step-12A/B Kopfkorrektur**. Erst dieser muss auf dem Fold wieder die bekannte stabile Basis bestätigen, bevor irgendein weiterer Bein- oder Walk-Fix versucht wird.


## Recovery-Build nach Regression

Der Recovery-Build wurde erfolgreich automatisiert validiert und exportiert.

- Build-/Validierungsbasis: `71f4af297038d43dd76d15145bc94b9ad8a53c0c`
- Workflow-Run: `36362768392` — **success**
- Nachweis-Commit: `34c4b02468099a0d71931a122465f2b29ce4c419`
- `scripts/main.gd` Git-Blob: `a32408d507f0ee1c928c766f214666bedad65175` — exakt Step 11
- `scenes/horse_cutout_rig.tscn` Git-Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac` — Step-11 Beine/Walk + ausschließlich Kopf 12A/12B
- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- echte Runtime-Hauptszene gestartet: **success**
- Android Debug Export: **success**
- Artifact: `Pferd-und-Steve-step12-recovery-apk`
- Artifact-ID: `10946058494`
- APK: `Pferd-und-Steve-step12-recovery-debug.apk`
- APK SHA-256: `fe86fb4354a07e6fd02a8f7559f4a2f0b7a1d425c838e1c9e9b78d1fd44edc44`

Dieser Build ist der **einzige gültige Step-12-Reteststand**. Der vorherige Step-12-Build bleibt verworfen.


## Collision-Regression — eigentliche Ursache und aspect-ratio-fester Fix

Der zweite echte Fold-Retest zeigte weiterhin klar falsche Hofgrenzen. Die Screenshots hatten eine effektive Spielfläche von **1536×658**, während die ursprünglichen obstacle-aware Grenzwerte aus einem **1536×1384**-Testbild als direkte Viewport-Ratios kalibriert worden waren.

Da der Farm-Hintergrund mit `cover` skaliert und zentriert gecroppt wird, sind direkte X-/Y-Prozentwerte des Viewports nicht stabil. Dadurch lagen die mathematischen Grenzen im Querformat nicht mehr auf den sichtbaren Heuballen / Unterstand-Bereichen.

### Fix

Runtime-Commit:
- `aa07a14d87ed983d2e7268fa701bae528f81f7c2` — `Make farm obstacle boundaries aspect-ratio aware`

Die bereits bestätigte historische Kalibrierung wurde **nicht neu geraten**, sondern aus dem alten 1536×1384-Screenshot in kanonische Farm-Texturkoordinaten der 1536×864-Farm zurückgerechnet:

- Left outer X: `288.5549`
- Left obstacle X: `633.7554`
- Left open X: `700.8777`
- Right open X: `1055.6671`
- Right obstacle X: `1122.7894`
- Right outer X: `1247.4451`
- Open ground Y: `488.16`
- Obstacle ground Y: `505.44`
- Outer ground Y: `518.40`

Diese Werte werden zur Laufzeit mit exakt demselben `cover`-Transform wie der Hintergrund in den aktuellen Viewport projiziert.

Für 1536×658 ergibt das ungefähr:
- X: `289 / 634 / 701 / 1056 / 1123 / 1247`
- Y: `385 / 402 / 415`

Für den alten 1536×1384-Fall ergeben dieselben Farm-Koordinaten wieder praktisch exakt die ursprüngliche Kalibrierung:
- X: `0 / 553 / 660 / 1229 / 1336 / 1536`
- Y: `782 / 810 / 830`

Zusätzlich wird nicht mehr nur der `HorseRoot`-Punkt geprüft:
- aktuelle projizierte Pferdebreite wird als Collision-Probe berücksichtigt
- links / Mitte / rechts des sichtbaren Pferdes werden gegen die Farm-Grenze geprüft
- Bildschirm-X wird mit einer tiefenabhängigen sichtbaren Pferde-Marge begrenzt
- dadurch kann der Root nicht mehr legal sein, während Körper/Kopf schon im Hindernis oder halb außerhalb des Screens liegen

### Schutz vor erneuten Rig-Regressionen

Der Validator erzwingt gleichzeitig:
- `scripts/main.gd` Blob: `98284df5dbaf8bed2210303929572e87f3444df5`
- `horse_cutout_rig.tscn` Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Damit blieb das Recovery-Rig **unverändert**: Step-11 Beine + Step-11 Walk + ausschließlich Kopf 12A/12B.

### Validierung / Android-Build

- Workflow-Run: `36363441866` — **success**
- Nachweis-Commit: `fe316d513892498372dcb4560624b69e03e2e700`
- 1536×658 Mapping-Test: **success**
- 1536×1384 Legacy-Mapping-Test: **success**
- Asset-Integrität: **success**
- Godot 4.3 Headless: **success**
- echte Hauptszene headless: **success**
- Android Debug Export: **success**
- Artifact: `Pferd-und-Steve-aspect-collision-fix-apk`
- Artifact-ID: `10946561870`
- APK SHA-256: `a30e097b41782094c1227f865f129d01a84009babda72308763139b35ac67c01`

Dieser Build ist jetzt der gültige Collision-Reteststand.


## Zaun-Klarstellung aus echtem Fold-Test

Der Nutzer hat die tatsächlichen relevanten Collision-Objekte anhand zweier echter Gerätescreenshots präzisiert:

- **1536×658 / kleines Querbild:** maßgebliche seitliche Sperre ist der **weiße Zaun ganz rechts**.
- **1536×1384 / großes Bild:** maßgebliche hintere Sperre ist der **weiße horizontale Zaun in der Mitte**.

Heuballen und Unterstand sind ausdrücklich **nicht** die Collision-Zielkante.

### Umsetzung

Commit:
- `07b575e7e780ba3320bc68f3f89294f7980b5cb3` — `Use visible farm fences as movement boundaries`

Runtime-Regeln:
- globaler hinterer Zaun bleibt die validierte rear-ground Grenze
- linke/rechte Vordergrund-Seitenzäune werden in Farm-Texturkoordinaten gespeichert
- Side fences werden nur als X-Wand verwendet, wenn sie nach Background-`cover` tatsächlich im aktuellen Viewport sichtbar sind
- ist ein Seitenzaun durch Cropping außerhalb des Bildes, wird dort nur gegen den sichtbaren Bildschirmrand begrenzt
- Heu-/Shelter-spezifische künstliche Tiefenkurve wurde entfernt

Gemessene Farm-X-Kanten aus dem echten 1536×658-Screenshot:
- linker Seitenzaun: `x=45`
- rechter Seitenzaun: `x=1416`

Projection:
- 1536×658 → links `45`, rechts `1416`, beide sichtbar
- 1536×1384 → links ca. `-390`, rechts ca. `1806`, beide außerhalb; dort bleibt der mittlere horizontale Zaun die relevante Rear-Collision

Schutz vor Rig-Regression:
- `horse_cutout_rig.tscn` Blob weiterhin unverändert: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- keine Bein-, Walk-, Kopf- oder Assetänderung in diesem Fix

Validierung:
- Godot-Validation Run `36364162114`: **success**
- Android Build Run `36364162142`: **success**
- Android Artifact-ID: `10946946741`
- lokal entpackte APK SHA-256: `f5e51d13ff4c5cf599246d959509b5d0a5710a5d2aefeea0f6e8c5cd1c1d8e37`

Dieser Build ist der aktuelle Zaun-Collision-Reteststand.

## Collision-Recovery auf den letzten user-approved Stand

Status: **technisch validierter Recovery-Kandidat / echter Fold-Gerätetest ausstehend**.

Die beiden späteren Collision-Experimente
`aa07a14d87ed983d2e7268fa701bae528f81f7c2` und
`07b575e7e780ba3320bc68f3f89294f7980b5cb3` wurden nach dem echten
Fold-Test ausdrücklich verworfen. Sie sind keine Collision-Referenz mehr.

### Verifizierte historische Basis

Der echte Diff von
`d5d3ff9ca32968f035d304176668eb2a326578ad`
zeigt die damals eingeführte und anschließend vom Nutzer bestätigte Semantik:

- offene hintere Hoffläche: `0.565 × Viewporthöhe`
- Hindernisbereiche: `0.585 × Viewporthöhe`
- äußerste Bereiche: `0.600 × Viewporthöhe`
- X-Profil: `0.00 / 0.36 / 0.43 / 0.80 / 0.87 / 1.00`
- `_minimum_projected_foot_y_ratio_for_x(...)`
- `_minimum_depth_t_for_x(...)`
- unerlaubte Tiefenziele werden auf den nächstliegenden legalen Bodenpunkt davor projiziert

Bestätigungsdokumentation:
`f34c9142c67c388758d7749fca2536ea51734b9d`.
Kalibrierungsdokumentation:
`bd064faffffcde52f494886b81d6215dd18f2560`.

### Warum kein Cutout-Adapter nötig ist

Die Git-History zeigt, dass die Cutout-Integration die physische Collision-Semantik
nicht verändert hat. Beim sichtbaren Austausch auf das Cutout-Rig
(`bfba37dbc058de129e2f2605a015241ae6bca2e7`) blieb `HorseRoot`
weiterhin der projizierte Welt-/Bodenpunkt. Der Cutout wird ausschließlich darunter
über

- `RigSpace.scale = 0.701686`
- `HorseCutoutRig.position.y = -516.7995`

auf denselben historischen sichtbaren Kalibrierraum abgebildet.

Der spätere Step-12-Recovery-Stand
`c8d10c7a8c84562275b2ec029b8fe281ec5116d0`
hat für `scripts/main.gd` exakt den Blob
`a32408d507f0ee1c928c766f214666bedad65175`.
Dieser Stand enthält bereits das heutige Cutout-Rig und gleichzeitig die alte
user-approved Collision-Mathematik. Deshalb wurde **kein neuer Anchor,
keine Bounding Box und keine Adapter-Mathematik erfunden**.

### Minimaler Runtime-Recovery

Runtime-Commit:
`fd0962080edf756030a0b2a5a06cb5c1315ea859`
— `Restore user-approved farm collision behavior`.

Geändert wurde ausschließlich:

- `scripts/main.gd`

Wiederhergestellter Blob:

- `scripts/main.gd`: `a32408d507f0ee1c928c766f214666bedad65175`

Explizit unverändert:

- `scenes/main.tscn`: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn`: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- Pferdeassets
- Bein-/Walk-Daten
- Kopfkorrekturen 12A/12B
- RigSpace-/Ground-Anchor-Werte
- Farmgrafik
- 1/Z-Perspektivmodell

Die folgenden experimentellen Collision-Pfade sind im Recovery-Code wieder entfernt:

- Farm-Source-Space-/Cover-Collision-Mapping
- `HORSE_HALF_WIDTH_TO_PROJECTED_HEIGHT`
- künstliche Links/Mitte/Rechts-Breitenprobes
- `_clamp_horse_screen_x(...)`
- `_minimum_depth_t_for_screen_x(...)`
- Side-Fence-X-Clamps

### Fail-closed Validierung und Android-Build

Temporärer Recovery-Validator:
`dc7924ac79ea244b0343e33f156a4fc02962e912`
— `Add approved collision recovery validation`.

Workflow-Run:
`36368232364` — **success**.

Der Validator hat geprüft:

- Recovery-Commit verändert exakt nur `scripts/main.gd`
- `main.gd`-Blob exakt `a32408d507f0ee1c928c766f214666bedad65175`
- `main.tscn`-Blob exakt `336c90377be17ac57fe9b611a455ee544da6ba85`
- Rig-Blob exakt `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- bestätigte `0.565 / 0.585 / 0.600`-Semantik vorhanden
- experimentelle Collision-Symbole nicht mehr vorhanden
- verifizierte Rig-Assets unverändert
- Godot 4.3 Editor/Parse: **success**
- echte `main.tscn` headless gestartet: **success**
- Android Debug Export: **success**

Android-Artefakt:

- Artifact: `Pferd-und-Steve-approved-collision-recovery-debug`
- Artifact-ID: `10947917953`
- APK: `Pferd-und-Steve-approved-collision-recovery-debug.apk`
- APK SHA-256: `d0b6d9995f9d2b4df837ed7b8fc6c61f0b1a61baacd51fbda8b2980aac86452c`

### Nächster Schritt — ausschließlich echter Fold-Test

Dieser Recovery-Stand ist technisch testbereit, aber **noch nicht als neuer
integrierter FROZEN-Baseline-Commit freigegeben**.

Auf dem Samsung Galaxy Z Fold7 jetzt nur Collision testen:

- 1536×1384: links hinten, Mitte hinten, rechts hinten, Heuballen,
  Scheune, Unterstand, äußerste X-Positionen, extreme Nähe
- 1536×658: links, rechts, hinten, sichtbarer weißer Zaun ganz rechts,
  Unterstand, Heuballen, Mitte, verschiedene Tiefen und LEFT/RIGHT

Bis zur ausdrücklichen Nutzerbestätigung keine weitere Runtime-Änderung.

