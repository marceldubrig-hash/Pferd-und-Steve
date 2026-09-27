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
