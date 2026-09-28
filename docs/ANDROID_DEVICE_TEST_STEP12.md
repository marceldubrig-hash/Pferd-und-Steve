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

### Cleanup des temporären Validators

Nach erfolgreichem Run und dauerhafter Dokumentation wurde ausschließlich der
temporäre Recovery-Workflow wieder entfernt:

- Cleanup-Commit: `39167054b96433b6bae30ea51b17beda54201ab8`
  — `Remove temporary collision recovery validator`
- keine Runtime-Datei, Scene, Animation oder Assetdatei wurde dabei verändert
- der erfolgreiche Run `36368232364` und das erzeugte APK-Artefakt bleiben als
  dokumentierter Nachweis erhalten

## Exact-Cutout Collision-Retest — dritte Recovery-Chance

Status: **technisch validiert / echter Fold-Gerätetest ausstehend**.

Runtime-Commit:
`98eb642fa4399d2bd5b7f649118a6cec0b3960a5`
— `Resolve farm collision from exact cutout bounds`.

### Geänderte Collision-Semantik

Die historische Hofkurve bleibt unverändert:
`0.565 / 0.585 / 0.600` mit den kalibrierten X-Stützstellen
`0.00 / 0.36 / 0.43 / 0.80 / 0.87 / 1.00`.

Neu ist ausschließlich die Art, **welcher X-Bereich gegen diese Kurve geprüft wird**:

- nicht mehr nur der `HorseRoot`-Punkt
- keine geschätzte Pferdebreite
- keine frei angenommene Bounding-Box-Ratio
- Godot liest die tatsächlichen aktuellen `Sprite2D`-Bounds des sichtbaren Cutout-Rigs
- die gesamte reale sichtbare X-Spanne wird gegen die bestehende Hofkurve geprüft
- die bekannten Stützstellen innerhalb dieser Spanne werden exakt mitbewertet
- bei Fold-Querformat werden die real sichtbaren Seitenzäune bei Farm-Source-X `45` und `1416` als horizontale Limits verwendet
- wenn diese Zäune im hohen Fold-Bild durch `cover` aus dem Viewport gecroppt sind, gelten ausschließlich die sichtbaren Bildschirmränder

Damit bleibt `HorseRoot` derselbe physische Bodenanker. Rig, Perspektive und Animation werden nicht umgebaut.

### Frozen-Dateien unverändert

- `scenes/main.tscn`: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn`: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`
- keine Assetänderung
- keine Walk-/Bein-/Kopf-/Layering-Änderung
- keine Änderung am `RigSpace.scale = 0.701686`
- keine Änderung am Ground-Anchor `-516.7995`

### Runtime-Validierung

Temporärer Validator:
`eeadb4585bddd63dff1e0959bcb0efd0dcb13cd3`
— `Add exact cutout collision runtime validation`.

Run:
`36374011658` — **success**.

Getestet wurden in echtem Godot 4.3:

- Viewport-Modell `1536×658`
- Viewport-Modell `1536×1384`
- RIGHT und LEFT
- X-Proben `0.00 / 0.18 / 0.34 / 0.40 / 0.50 / 0.82 / 0.90 / 1.00`
- Tiefen `0.00 / 0.28 / 0.60`

Für jede Kombination wurde geprüft:

- tatsächliche Sprite-Grenze links bleibt innerhalb des erlaubten Bereichs
- tatsächliche Sprite-Grenze rechts bleibt innerhalb des erlaubten Bereichs
- im breiten Fold-Bild: sichtbare Fence-Limits exakt ungefähr `45 … 1416`
- im hohen Fold-Bild: Seitenzäune korrekt herausgecroppt, Limits `0 … 1536`
- projizierter Hufpunkt liegt mindestens auf der strengsten historischen Hofgrenze innerhalb der gesamten sichtbaren Pferdespanne

Der Runtime-Validator endete mit:
`PASS exact cutout collision for both Fold sizes, both directions, and extreme X/depth probes`.

### Android-Testbuild

- Godot-Parse-Run: `36373925689` — **success**
- Android-Build-Run: `36373925737` — **success**
- Artifact-ID: `10949734349`
- APK: `Pferd-und-Steve-exact-cutout-collision-debug.apk`
- APK SHA-256:
  `b8af37bb6b6c21c5620472b72bdfb760fd02e77889a53c560ae997798d371feb`

Dieser Stand wird erst nach echter Bestätigung auf dem Samsung Galaxy Z Fold7 als
neue integrierte FROZEN-Collision-Baseline übernommen.

## Exact-Cutout-Collision — 4-Pixel-Micro-Kalibrierung (Fold-Test ausstehend)

Status: **automatisiert verifiziert / echter Fold-Test ausstehend / noch nicht FROZEN**

Die auf dem echten Samsung Galaxy Z Fold7 als **fast richtig** bewertete
Exact-Cutout-Collision aus `98eb642fa4399d2bd5b7f649118a6cec0b3960a5`
bleibt vollständig erhalten. Die einzige Runtime-Änderung ist ein gemeinsamer
`COLLISION_BOUNDARY_INSET_PX := 4.0` auf den bereits berechneten hinteren und
seitlichen Exact-Cutout-Grenzen.

Unverändert bleiben insbesondere:

- historische Ground-Curve `0.565 / 0.585 / 0.600`
- echte Sprite2D-Cutout-Bounds
- Fold-Cover- und Side-Fence-Auswertung
- Perspektive und HorseRoot-Ground-Anchor
- `main.tscn`
- komplettes Cutout-Rig, Kopf-Fixes, Walk, Layering und Assets

Technischer Stand:

- Runtime-Commit: `7dfa0533fb8ae055fb69b3107da6aebfb089e86a`
- Runtime-Commit-Inhalt: ausschließlich `scripts/main.gd`
- temporärer Validator-Commit: `8c2edb0b2719d97b5dd94ddf47c12968e9e138f7`
- temporärer Validator-Cleanup: `b48dcfabe1b4ca269f70ef0480e3c7c501ae173d`
- Godot-4.3-Parse-Run: `36374978165` — **SUCCESS**
- Collision-Validator-Run: `36375016331` — **SUCCESS**
- Validator-Artifact-ID: `10950423676`
- Android-Debug-Build-Run: `36374978188` — **SUCCESS**
- Android-Artifact-ID: `10950582615`
- APK: `Pferd-und-Steve-collision-micro-calibration-debug.apk`
- APK SHA-256: `3bfc9c188ef87b1fd92c752318979435c7257a65740b8a26f74c2d22c2a71b62`
- `scripts/main.gd` Blob: `214a87a755b2c8e7550f16ca78bd58cb2a919aff`
- `scenes/main.tscn` Blob: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn` Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Automatisiert geprüft:

- 1536×658
- 1536×1384
- RIGHT und LEFT
- X-Proben 0.00, 0.18, 0.34, 0.40, 0.50, 0.82, 0.90 und 1.00
- Tiefen 0.00, 0.28 und 0.60
- echte sichtbare Cutout-Spanne innerhalb der neuen Grenzen
- hintere Ground-Curve inklusive 4-Pixel-Inset
- breite Fold-Grenzen `49 … 1412`
- hohe Fold-Grenzen `4 … 1532`

Der Kandidat darf erst nach ausdrücklicher Nutzerbestätigung auf dem echten
Samsung Galaxy Z Fold7 als USER APPROVED / FROZEN in `MASTER_SPEC.md`
eingetragen werden.

### Wide-Fold-Nachkalibrierung nach echtem Gerätetest

Gerätefeedback auf Samsung Galaxy Z Fold7 / Android 16:

- hohes/großes Format: **passt**, Verhalten mit 4-Pixel-Inset bleibt unverändert
- kleines/breites Format: Grenzen noch leicht zu großzügig
- erlaubte Folgeänderung: ausschließlich breites Format von 4 auf 8 Pixel Inset

Technischer Stand:

- Runtime-Commit: `2984fadda8464a034992f5992133913cb095b1c6`
- Runtime-Commit-Inhalt: ausschließlich `scripts/main.gd`
- hohes/großes Fold: weiterhin exakt `4 px`
- kleines/breites Fold: jetzt exakt `8 px`
- temporärer Validator-Commit: `2f21d2ed485f2633fcf994441fef238ff37c2b7e`
- temporärer Validator-Cleanup: `94f23d2fd597bd627c9a0d25d3f4459a1ce73815`
- Godot-4.3-Parse-Run: `36375398912` — **SUCCESS**
- Collision-Validator-Run: `36375423043` — **SUCCESS**
- Validator-Artifact-ID: `10950797336`
- Android-Debug-Build-Run: `36375398904` — **SUCCESS**
- Android-Artifact-ID: `10950961311`
- APK: `Pferd-und-Steve-wide-fold-collision-calibration-debug.apk`
- APK SHA-256: `2d00e15809d16c074de3d356409c6d83c98a39ee9ebde1c3894137ff6e252922`
- `scripts/main.gd` Blob: `117998e0e4073f6436bfc30123f75bca90ae24f0`
- `scenes/main.tscn` Blob: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn` Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Automatisierte erwartete Grenzen:

- 1536×658: `53 … 1408` (8-Pixel-Inset)
- 1536×1384: `4 … 1532` (unverändert 4-Pixel-Inset)

Status: **breiter Fold-Gerätetest ausstehend / noch nicht vollständig FROZEN**.
Das bestätigte hohe Format darf bei weiteren Nachjustierungen nicht verändert werden.

### Lokale Wide-Fold-Grenze am linken Pfosten der rechten Hütte

Neue echte Fold-Referenzen: `22961.jpg`, `22963.jpg`, `22965.jpg`,
`22969.jpg`.

Befund:

- rechter Zaun, rechte Hüttenkante und linker Scheunenbereich zeigen brauchbare Zielpositionen
- bei der hinteren Position um `x≈1120` konnte das Pferd noch sichtbar durch den
  linken senkrechten Stützpfosten der kleinen rechten Hütte stehen
- eine weitere globale Verengung wäre falsch, weil sie bereits passende Kanten
  ebenfalls verschieben würde

Isolierte Lösung:

- kanonischer Pfosten-Stützpunkt: `WIDE_SHELTER_LEFT_POST_SOURCE_X := 1120.0`
- gilt ausschließlich im breiten Fold-Layout
- greift nur, wenn die echte aktuelle Cutout-Spanne den sichtbaren Pfosten schneidet
- verwendet die bestehende kanonische äußere Hufgrenze `0.600`
- bestehendes Wide-Fold-Inset `8 px` bleibt erhalten
- hohes/großes Fold bleibt vollständig unverändert

Technischer Stand:

- Runtime-Commit: `6e30a169067dab52b0c788358d2686391f96f152`
- Runtime-Commit-Inhalt: ausschließlich `scripts/main.gd`
- erster temporärer Validator-Commit: `00f8d2863bc1a66e2ac1c48c5f68ed71a8408858`
- reine Validator-Typkorrektur: `d2958fab42bf693beac3988020ae0c2158a9fe83`
- temporärer Validator-Cleanup: `7c9dd17a3835cdd0340ec62291dcc75ab7f433fa`
- Godot-4.3-Parse-Run: `36375985744` — **SUCCESS**
- Collision-Validator-Run: `36376097268` — **SUCCESS**
- Validator-Artifact-ID: `10950833233`
- Android-Debug-Build-Run: `36375985743` — **SUCCESS**
- Android-Artifact-ID: `10951315565`
- APK: `Pferd-und-Steve-shelter-post-collision-debug.apk`
- APK SHA-256: `53af4187551fbf1a0e3df1a58db2c2de24631a89be12223ad3e7f93e209974bb`
- `scripts/main.gd` Blob: `f31c6d82592ab5bee6f6591f7d567f3e0b658ef8`
- `scenes/main.tscn` Blob: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn` Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Gezielte Validator-Probe:

- kleines Fold `1536×658`
- `x_ratio = 0.73`
- LEFT und RIGHT
- resultierende Mindest-Huflinie: `0.612158… = 0.600 + 8/658`
- bestehende Seitenlimits bleiben `53 … 1408`
- großes Fold bleibt bei den bisherigen 4-Pixel-Grenzen

Status: **echter Wide-Fold-Gerätetest ausstehend / noch nicht FROZEN**.

### Gezeichnete Wide-Fold-Bodenbegrenzung aus 22978.jpg

Der Nutzer hat die gewünschte begehbare Rückgrenze im echten Wide-Fold-Screenshot
`22978.jpg` als blaue Linie eingezeichnet. Diese visuelle Vorgabe ersetzt für
das breite Fold-Layout die vorherigen groben lokalen Rückgrenzen.

Umsetzung:

- 23 aus der blauen Linie gemessene und normalisierte Stützpunkte
- glatte Interpolation zwischen benachbarten Punkten
- echte aktuelle Cutout-Spanne wird weiterhin vollständig ausgewertet
- alle innerhalb der Pferdespanne liegenden Kurvenstützpunkte werden geprüft
- die gezeichnete Linie selbst ist die finale Hufgrenze; kein zusätzlicher
  vertikaler 8-Pixel-Inset wird darauf addiert
- bestehende seitliche Wide-Fold-Limits bleiben `53 … 1408`
- hohes/großes Fold verwendet weiterhin unverändert die historische Kurve und
  den bestätigten 4-Pixel-Inset

Ausgewählte gemessene Referenzpunkte:

- `x=430 → y=400`
- `x=530 → y=428`
- `x=820 → y=395`
- `x=1120 → y=420`
- `x=1400 → y=433`

Technischer Stand:

- Kurven-Commit: `8420b24e5413ae0a2741714fc80555098ab64ee4`
- isolierter Runtime-Aufruffix: `144f13ea4f2740024c5ccfbb3df3c6b93adbfc71`
- Runtime-Änderungen betreffen ausschließlich `scripts/main.gd`
- temporärer Validator-Commit: `88e3422a5158b6fc5a8400ef5e4b3ecb4cfc8db5`
- Validator-Retarget-Commit: `954fc784d090231be5643325e650b452e9bedd69`
- temporärer Validator-Cleanup: `4c66fc927b16dcef71bc4a64835ea0c860e07cd2`
- Godot-4.3-Parse-Run: `36376969653` — **SUCCESS**
- Collision-Validator-Run: `36376982492` — **SUCCESS**
- Validator-Artifact-ID: `10951745842`
- Android-Debug-Build-Run: `36376969750` — **SUCCESS**
- Android-Artifact-ID: `10951381157`
- APK: `Pferd-und-Steve-drawn-wide-boundary-debug.apk`
- APK SHA-256: `d2e0631b26941b2d24ac40c6197cd7479405ad841eae4c10ec84fdb2c277f2c1`
- `scripts/main.gd` Blob: `04966694a5354ec2255a422bef74c21b7b6061e8`
- `scenes/main.tscn` Blob: `336c90377be17ac57fe9b611a455ee544da6ba85`
- `scenes/horse_cutout_rig.tscn` Blob: `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Automatisiert geprüft:

- fünf feste Punkte direkt aus der blauen Referenzlinie
- 1536×658 und 1536×1384
- LEFT und RIGHT
- extreme X-Positionen und mehrere Tiefen
- große Fold-Collision unverändert
- Rig-/Scene-Blobs unverändert

Status: **echter Wide-Fold-Gerätetest ausstehend / noch nicht FROZEN**.

