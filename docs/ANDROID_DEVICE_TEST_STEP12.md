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
