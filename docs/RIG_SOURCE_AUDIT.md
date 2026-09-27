# RIG SOURCE AUDIT — Phase 1

Stand: 2026-09-27

## Zweck

Diese Datei dokumentiert ausschließlich den tatsächlich verifizierten Stand der bereits bestätigten Pferde-Cutout-Assets auf GitHub `main`.

Keine Farm-, Perspektiv-, Bewegungs- oder Designentscheidung wurde dabei verändert.

Basis des Audits:
- Ausgangsstand vor dem Audit: `f34c9142c67c388758d7749fca2536ea51734b9d`
- Audit-Script: `tools/audit_rig_source_assets.py`
- Audit-Workflow: `.github/workflows/audit-rig-source-assets.yml`
- erster Audit-Run: `36326551844`

Der Audit arbeitet absichtlich fail-closed: Fehlt ein bestätigtes Asset oder ist es nicht eindeutig identifizierbar, wird nichts geraten, ersetzt oder neu generiert.

## Tatsächlich versionierte Source-Pakete

### `asset_packs/Pferd-und-Steve-source-core-v01.zip`

Verifizierter Inhalt:

- `farm_day_v01.png`
- `farm_night_v01.png`
- `horse_master_standing_v01.png`
- `horse_master_standing_75pct_v01.png`
- `horse_master_standing_50pct_v01.png`
- `horse_master_standing_35pct_v01.png`

### `asset_packs/Pferd-und-Steve-source-head-core-v01.zip`

Verifizierter Inhalt:

- `horse_head_upper_v01.png`
- `horse_jaw_v01.png`

## Status der bestätigten Rig-Assets

| Asset | Auf main als Source verifiziert | Aktueller Hinweis |
|---|---|---|
| `horse_master_standing_v01.png` | ja | zusätzlich bereits Runtime-Asset |
| `horse_head_upper_v01.png` | ja | im Head-Source-Paket |
| `horse_jaw_v01.png` | ja | im Head-Source-Paket |
| `horse_head_talk_halfopen_preview_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |
| `horse_head_talk_open_preview_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |
| `horse_body_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |
| `horse_tail_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |
| `horse_front_legs_segments_sheet_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |
| `horse_hind_legs_segments_sheet_v01.png` | nein | bestätigt, aber noch nicht in einem Source-Paket auf main |

## Wiedergefundene Originalkandidaten außerhalb des Repositories

Die früher erzeugten Bilddateien wurden in der bestehenden ChatGPT-Dateibibliothek wiedergefunden. Sie wurden **nicht neu generiert**.

Visuell eindeutig wiedergefunden:

- Körperkern
- separater Schweif
- Vorderbein-Segment-Sheet
- Hinterbein-Segment-Sheet
- zwei bereits erzeugte Mund-Vorschauen mit unterschiedlich weit geöffnetem Unterkiefer

Diese Dateien gelten gemäß Projektregel **noch nicht als Repository-Canon**, solange ihre exakten Binärdateien nicht sicher auf `main` versioniert sind.

## Ergebnis von Phase 1

Phase 1 hat einen realen Source-Inventarfehler gefunden:

Die Dokumentation nennt acht bestätigte Cutout-Komponenten, aber auf `main` sind davon derzeit nur `horse_head_upper_v01.png` und `horse_jaw_v01.png` in den Rig-Source-Paketen vorhanden.

Der Audit-Run `36326551844` ist deshalb erwartungsgemäß fehlgeschlagen. Das ist kein Rig-Codefehler, sondern ein bewusst sichtbarer Source-Asset-Blocker.

## Nächster erlaubter Schritt

Vor Phase 2 müssen die **bereits bestätigten, wiedergefundenen Originaldateien** ohne Neugenerierung und ohne Designänderung sicher auf `main` versioniert werden.

Danach:

1. Audit erneut laufen lassen.
2. Erst bei grünem Asset-Audit Body + HeadUpper + Jaw in einer separaten Rig-Testszene zusammensetzen.
3. Farm-/Perspektivsystem dabei unangetastet lassen.
