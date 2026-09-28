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
