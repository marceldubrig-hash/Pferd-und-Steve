# RIG RECOVERY CHECKSUMS

Stand: 2026-09-27

Dieses Dokument fixiert die SHA-256-Fingerabdrücke der wiedergefundenen, bereits bestätigten Rig-Originaldateien.

Die Dateien wurden aus der bestehenden ChatGPT-Dateibibliothek wiedergefunden, **nicht neu generiert** und beim Erstellen des Recovery-Pakets nicht neu encodiert. Es wurde lediglich der Dateiname auf den kanonischen Projektnamen normalisiert.

Vorgesehener Paketname:

`asset_packs/Pferd-und-Steve-source-rig-missing-v01.zip`

## Erwartete SHA-256-Werte

| Kanonische Datei | SHA-256 |
|---|---|
| `horse_head_talk_halfopen_preview_v01.png` | `43f186bf8032f4decc51a077ae19d0a399f6b5523cfdf815581378c6610a3051` |
| `horse_head_talk_open_preview_v01.png` | `04b188a6f78c18a6cb511711cc46849319163cd62ed8a8c982ded244df514930` |
| `horse_body_v01.png` | `5273e578ab5edf4f3345f4011182f2cf64fe8cdb326f2e93c7bceecb6a819606` |
| `horse_tail_v01.png` | `b608633b49b8cf6eb3dd612cf2482d9b482c4bfc7d8a72dbf9a4ecb1c7d58fe1` |
| `horse_front_legs_segments_sheet_v01.png` | `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a` |
| `horse_hind_legs_segments_sheet_v01.png` | `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3` |

## Validierungsregel

Sobald das Recovery-Paket auf GitHub `main` liegt:

1. ZIP-Integrität prüfen.
2. Jede der sechs Dateien anhand des kanonischen Namens eindeutig finden.
3. SHA-256 gegen diese Tabelle prüfen.
4. Bei irgendeiner Abweichung abbrechen.
5. Keine Datei ersetzen, korrigieren oder neu generieren.
