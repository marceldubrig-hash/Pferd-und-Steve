# ASSET MANIFEST

Stand: 2026-09-27

## Canon-Hintergründe

| Zielpfad | Status | Beschreibung |
|---|---|---|
| assets/backgrounds/farm_day_v01.png | Quelle bestätigt | Canon-Farm am Tag |
| assets/backgrounds/farm_night_v01.png | Quelle bestätigt | identische Canon-Farm bei Nacht |

## Pferd

| Zielpfad | Status | Beschreibung |
|---|---|---|
| assets/horse/horse_master_standing_v01.png | generiert + bestätigt | vollständiges stehendes Master-Pferd, Seitenansicht rechts |
| assets/horse/horse_head_upper_v01.png | generiert + bestätigt | fester Kopf/oberer Kopf ohne beweglichen Unterkiefer |
| assets/horse/horse_jaw_v01.png | generiert + bestätigt | separater klappbarer Unterkiefer |
| assets/horse/horse_head_talk_halfopen_preview_v01.png | generiert + bestätigt | Vorschau: Unterkiefer leicht geöffnet |
| assets/horse/horse_head_talk_open_preview_v01.png | generiert + bestätigt | Vorschau: Unterkiefer weit geöffnet |
| assets/horse/horse_body_v01.png | generiert + bestätigt | Körperkern für Cutout-Rig |
| assets/horse/horse_tail_v01.png | generiert + bestätigt | separater Schweif |
| assets/horse/horse_front_legs_segments_sheet_v01.png | generiert + bestätigt | sechs Segmente der beiden Vorderbeine |
| assets/horse/horse_hind_legs_segments_sheet_v01.png | generiert + bestätigt | sechs Segmente der beiden Hinterbeine |

## Größenvarianten für Tests

Vom Master-Pferd sollen zusätzlich reine Skalierungsvarianten ohne Designänderung vorhanden sein:

- horse_master_standing_75pct_v01
- horse_master_standing_50pct_v01
- horse_master_standing_35pct_v01

## Verbindliche Regel

Keine bestätigten Assets neu erfinden. Varianten werden nur durch Skalieren, Spiegeln, Zuschneiden oder gezielte Korrektur des bestehenden Canon-Assets erstellt.

## Bestätigte Quelldateien für den ersten Runtime-Test

Die drei Canon-Quellen wurden in der ChatGPT-Dateibibliothek wiedergefunden und visuell gegen die Spezifikation geprüft:

| Zielpfad | Quelldatei | Maße | Alpha |
|---|---|---:|---|
| assets/backgrounds/farm_day_v01.png | image-gen-1(2).png | 1672×941 | nein |
| assets/backgrounds/farm_night_v01.png | image-gen-2(2).png | 1672×941 | nein |
| assets/horse/horse_master_standing_v01.png | image-gen-1(3).png | 1448×1086 | ja |

Die Tag-/Nacht-Farm ist dieselbe bestätigte Szene mit großer roter Scheune links, freiem Hof in der Mitte, weißem Zaun und offenem Unterstand rechts. Das Master-Pferd ist die bestätigte rechte Seitenansicht mit transparentem Hintergrund.

## Technischer Importstatus

- Projektstruktur und Spezifikation sind im Repository gesichert.
- Die ursprünglichen Binärpakete liegen versioniert unter `asset_packs/`.
- Canon-Tagfarm, Canon-Nachtfarm und das Master-Pferd liegen bereits in ihren verbindlichen `assets/...`-Runtime-Pfaden.
- Der aktuelle Rig-Source-Audit ist in `docs/RIG_SOURCE_AUDIT.md` dokumentiert.
- In den vorhandenen Rig-Source-Paketen auf `main` sind derzeit nur `horse_head_upper_v01.png` und `horse_jaw_v01.png` von den separaten Cutout-Komponenten tatsächlich versioniert.
- Die bereits bestätigten Dateien für Mund-Previews, Körper, Schweif sowie Vorder-/Hinterbein-Segment-Sheets wurden außerhalb des Repositories wiedergefunden, gelten aber erst nach unveränderter Versionierung auf `main` als verfügbarer Repository-Canon.
- Bis diese exakten Originaldateien sicher auf `main` liegen, darf Phase 2 des Rigs nicht auf geratenen, neu generierten oder ersetzten Assets aufbauen.
- Der CI-Audit arbeitet absichtlich fail-closed und bleibt rot, solange bestätigte Rig-Quellen fehlen.
