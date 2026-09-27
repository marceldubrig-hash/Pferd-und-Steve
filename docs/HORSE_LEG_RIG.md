# HORSE LEG RIG — verified segment-sheet mapping

Stand: 2026-09-27

## Scope

Diese Datei dokumentiert ausschließlich die technische Analyse der zwei bereits bestätigten Bein-Segment-Sheets. In diesem Schritt wurden **keine** Beinsegmente exportiert, **keine** Runtime-Texturen verändert, **keine** Szene verändert und **kein** Bein-Rig gebaut.

Analysierte Originale:

- `assets/horse/rig/horse_front_legs_segments_sheet_v01.png`
- `assets/horse/rig/horse_hind_legs_segments_sheet_v01.png`

Die Analyse lief direkt auf GitHub `main` gegen die dort liegenden Originalbytes. Verfeinerter Analyse-Run: `36331705192` — **success**.

## Asset-Integrität

| Sheet | Native Größe | Modus | Dateigröße | SHA-256 |
| --- | ---: | --- | ---: | --- |
| Front | 1122 × 1402 px | RGBA | 934199 Byte | `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a` |
| Hind | 1122 × 1402 px | RGBA | 1083253 Byte | `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3` |

Beide SHA-256-Werte stimmen mit den bereits im fail-closed Materializer festgeschriebenen Hashes überein. Die PNGs wurden bei der Analyse nicht neu encodiert oder verändert.

## Koordinatensystem und Alpha-Regel

Alle Koordinaten beziehen sich auf das jeweilige 1122×1402-Quellbild:

- Ursprung `(0,0)` = links oben
- Bounding-Box-Format = `(x, y, width, height)`
- die unten dokumentierten Segmentboxen verwenden einen robusten Alpha-Schwellwert `alpha >= 16`
- die Kandidaten für Gelenkanker sind Mittelwerte der sichtbaren Pixel in den oberen bzw. unteren ca. 8 % der jeweiligen robusten Segmentbox

Warum nicht einfach `alpha > 0`:

- das Front-Sheet enthält bei `alpha > 0` 409 winzige isolierte Alpha-Komponenten unter 200 Pixeln
- das Hind-Sheet enthält bei `alpha > 0` 703 solche Kleinstkomponenten
- beim Hind-Sheet verbinden extrem schwache Alpha-Reste bei `alpha > 0` sogar Upper und Lower scheinbar miteinander; dadurch entstehen fälschlich nur vier große Connected Components
- bereits ab `alpha >= 4` werden in beiden Sheets stabil sechs große Komponenten erkannt
- bei `alpha >= 16`, `64` und `128` bleiben ebenfalls exakt sechs große Komponenten erhalten

Damit ist `alpha >= 16` für die technische Zuordnung robust genug, ohne die sichtbaren Teile praktisch abzuschneiden.

Globale rohe Alpha-Ausdehnung, ausdrücklich **nicht** als Exportbox verwenden:

- Front, `alpha > 0`: `[0, 30) → [1100, 1378)`, 391703 nichttransparente Pixel
- Hind, `alpha > 0`: `[0, 48) → [1108, 1347)`, 452678 nichttransparente Pixel

## Front-Sheet — bestätigte Struktur

Das Front-Sheet enthält **zwei vollständige, unterschiedliche 3-Segment-Ketten**. Die Ketten sind im Sheet klar als linke und rechte Spalte organisiert.

Anatomische/rig-technische Bedeutung:

- **Upper** = Schulter/proximaler Vorderbein-Bereich bis zum ersten künstlichen Cut
- **Lower** = mittlerer Vorderbein-Abschnitt zwischen erstem und zweitem Cut
- **Hoof** = distaler dunkler Bein-/Pasternbereich einschließlich Huf

Die Cut-Linien sind bewusst für das Cutout-Rig gemacht und werden **nicht** als exakte veterinäranatomische Gelenkgrenzen interpretiert.

### Front — linke Sheet-Kette

| Rolle | Analyse-ID | robuste Box `(x,y,w,h)` | Top-Anker Quelle | Bottom-Anker Quelle | lokale Top-/Bottom-Anker innerhalb der Box |
| --- | --- | --- | --- | --- | --- |
| Upper | `T16_C1` | `(183, 32, 361, 608)` | `(383.250, 60.076)` | `(330.435, 610.582)` | top `(200.250, 28.076)`, bottom `(147.435, 578.582)` |
| Lower | `T16_C3` | `(208, 651, 171, 330)` | `(296.709, 667.818)` | `(272.355, 965.993)` | top `(88.709, 16.818)`, bottom `(64.355, 314.993)` |
| Hoof | `T16_C5` | `(240, 1000, 222, 305)` | `(283.641, 1014.082)` | `(382.117, 1291.115)` | top `(43.641, 14.082)`, bottom `(142.117, 291.115)` |

Spätere Gelenk-Paare:

- Upper → Lower: Upper-Bottom `(330.435, 610.582)` ↔ Lower-Top `(296.709, 667.818)`
- Lower → Hoof: Lower-Bottom `(272.355, 965.993)` ↔ Hoof-Top `(283.641, 1014.082)`

### Front — rechte Sheet-Kette

| Rolle | Analyse-ID | robuste Box `(x,y,w,h)` | Top-Anker Quelle | Bottom-Anker Quelle | lokale Top-/Bottom-Anker innerhalb der Box |
| --- | --- | --- | --- | --- | --- |
| Upper | `T16_C2` | `(715, 64, 274, 592)` | `(823.478, 91.355)` | `(826.209, 629.543)` | top `(108.478, 27.355)`, bottom `(111.209, 565.543)` |
| Lower | `T16_C4` | `(767, 675, 143, 309)` | `(837.557, 690.998)` | `(842.988, 969.852)` | top `(70.557, 15.998)`, bottom `(75.988, 294.852)` |
| Hoof | `T16_C6` | `(766, 1007, 220, 289)` | `(834.873, 1020.041)` | `(909.641, 1282.732)` | top `(68.873, 13.041)`, bottom `(143.641, 275.732)` |

Spätere Gelenk-Paare:

- Upper → Lower: Upper-Bottom `(826.209, 629.543)` ↔ Lower-Top `(837.557, 690.998)`
- Lower → Hoof: Lower-Bottom `(842.988, 969.852)` ↔ Hoof-Top `(834.873, 1020.041)`

## Hind-Sheet — bestätigte Struktur

Auch das Hind-Sheet enthält **zwei vollständige, unterschiedliche 3-Segment-Ketten**.

Anatomische/rig-technische Bedeutung:

- **Upper** = Hinterhand/Oberschenkel-proximaler Hinterbein-Bereich bis zum ersten künstlichen Cut
- **Lower** = mittlerer Hinterbein-Abschnitt zwischen den beiden Cuts
- **Hoof** = distaler dunkler Bein-/Pasternbereich einschließlich Huf

Wichtig: Bei reinem `alpha > 0` werden Upper und Lower jeder Spalte durch schwächste Alpha-Artefakte scheinbar verbunden. Das ist **kein** echtes zusammenhängendes Segment. Ab `alpha >= 4` sind die sechs visuellen Teile stabil getrennt.

### Hind — linke Sheet-Kette

| Rolle | Analyse-ID | robuste Box `(x,y,w,h)` | Top-Anker Quelle | Bottom-Anker Quelle | lokale Top-/Bottom-Anker innerhalb der Box |
| --- | --- | --- | --- | --- | --- |
| Upper | `T16_C1` | `(164, 53, 368, 519)` | `(368.816, 78.147)` | `(311.899, 548.097)` | top `(204.816, 25.147)`, bottom `(147.899, 495.097)` |
| Lower | `T16_C3` | `(174, 553, 212, 353)` | `(293.638, 566.259)` | `(245.255, 890.011)` | top `(119.638, 13.259)`, bottom `(71.255, 337.011)` |
| Hoof | `T16_C6` | `(149, 921, 253, 405)` | `(225.659, 941.502)` | `(312.766, 1308.003)` | top `(76.659, 20.502)`, bottom `(163.766, 387.003)` |

Spätere Gelenk-Paare:

- Upper → Lower: Upper-Bottom `(311.899, 548.097)` ↔ Lower-Top `(293.638, 566.259)`
- Lower → Hoof: Lower-Bottom `(245.255, 890.011)` ↔ Hoof-Top `(225.659, 941.502)`

### Hind — rechte Sheet-Kette

| Rolle | Analyse-ID | robuste Box `(x,y,w,h)` | Top-Anker Quelle | Bottom-Anker Quelle | lokale Top-/Bottom-Anker innerhalb der Box |
| --- | --- | --- | --- | --- | --- |
| Upper | `T16_C2` | `(646, 65, 353, 515)` | `(790.429, 89.378)` | `(829.659, 558.152)` | top `(144.429, 24.378)`, bottom `(183.659, 493.152)` |
| Lower | `T16_C4` | `(764, 553, 226, 356)` | `(838.995, 565.942)` | `(908.740, 891.626)` | top `(74.995, 12.942)`, bottom `(144.740, 338.626)` |
| Hoof | `T16_C5` | `(751, 916, 262, 407)` | `(931.206, 936.956)` | `(836.578, 1304.763)` | top `(180.206, 20.956)`, bottom `(85.578, 388.763)` |

Spätere Gelenk-Paare:

- Upper → Lower: Upper-Bottom `(829.659, 558.152)` ↔ Lower-Top `(838.995, 565.942)`
- Lower → Hoof: Lower-Bottom `(908.740, 891.626)` ↔ Hoof-Top `(931.206, 936.956)`

## Near/Far-Zuordnung — ursprünglicher Analyse-Stand

Technisch eindeutig bestätigt ist:

- jedes Sheet enthält eine **linke komplette 3er-Kette**
- jedes Sheet enthält eine **rechte komplette 3er-Kette**
- die beiden Ketten sind echte unterschiedliche Varianten

Nicht eindeutig aus den PNGs selbst belegt ist, welche Spalte semantisch **Near** bzw. **Far** heißen soll.

Es gibt:

- keine Near/Far-Beschriftung im Sheet
- keine entsprechende Metadatenmarkierung
- keine bereits vorhandene Texturzuweisung in `horse_cutout_rig.tscn`
- nur eine flach gerenderte Master-Pose, aus der die ursprüngliche Z-Reihenfolge der beiden Beine nicht beweissicher rekonstruiert werden kann

Deshalb wurde im reinen Analyseschritt **keine** Near/Far-Zuordnung erfunden. Diese Aussage beschreibt den Stand vor Schritt 4; der kontrollierte Montagevergleich aus Schritt 4 hat die Front-Zuordnung inzwischen aufgelöst.

## Wiederverwendung / Spiegelung

Die beiden Varianten pro Sheet sind **nicht** bloß dieselbe Form horizontal gespiegelt:

- ihre robusten Bounding-Box-Abmessungen unterscheiden sich
- Kontur und Textur unterscheiden sich sichtbar
- die analysierten RGBA-Crops haben unterschiedliche SHA-256-Werte

Daher:

- **keine** Segmentvariante durch simples Spiegeln der anderen ersetzen
- beide 3er-Ketten separat verwenden
- LEFT/RIGHT der Spielfigur weiterhin ausschließlich durch horizontales Spiegeln des **gesamten Rigs** erzeugen

## Layering-Hinweise für den späteren Aufbau

Noch keine Z-Werte festschreiben, solange Near/Far nicht verifiziert ist.

Sobald die Zuweisung bestätigt ist, gilt als geplantes Prinzip:

- Far-Beinkette hinter dem Body
- Near-Beinkette vor dem Body
- Cut-Enden durch kleine Transform-Überlappung verstecken, nicht durch Bildbearbeitung
- Upper → Lower → Hoof bleibt eine reine Rotations-/Pivot-Kette
- keine eigene Links/Rechts-Spiegelung einzelner Segmente

## Was in diesem Schritt ausdrücklich NICHT passiert ist

- keine sechs oder zwölf Einzel-PNGs exportiert
- keine Sheet-Datei verändert
- keine Textur in `horse_cutout_rig.tscn` eingetragen
- keine Near/Far-Annahme als Canon gesetzt
- keine Walk-Animation gebaut
- keine Farm-/Perspektivdatei verändert

## Schritt 4A — erste Kette festgelegt

Für den ersten kontrollierten Montageversuch wird ausschließlich die **linke Spalte des Front-Sheets** verwendet. Diese Kette bleibt semantisch neutral und heißt während der Montage **FrontLeftColumn**; sie wird ausdrücklich noch **nicht** als Near oder Far kanonisiert.

Quelle:

- Sheet: `assets/horse/rig/horse_front_legs_segments_sheet_v01.png`
- gepinnter SHA-256: `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`
- Upper: `T16_C1`, Region `(183, 32, 361, 608)`
- Lower: `T16_C3`, Region `(208, 651, 171, 330)`
- Hoof: `T16_C5`, Region `(240, 1000, 222, 305)`

Es werden **keine neuen PNG-Dateien** erzeugt. Die Scene verwendet `AtlasTexture`-Regions direkt aus dem unveränderten bestätigten Front-Sheet. Dadurch bleiben die Originalbytes unangetastet und es findet weder Re-Encoding noch Redraw statt.

Kalibrierhinweis:

- die Repository-Masterdatei wird technisch als `1024 × 768` gelesen
- die bereits bestätigten Cutout-Transforms verwenden den bisherigen `1448 × 1086`-Referenzraum
- beide Seitenverhältnisse sind identisch; der lineare Referenzfaktor beträgt exakt `1.4140625`
- die Master-Alpha-Silhouette trennt die beiden Vorderbeine ab ungefähr `y = 520` klar in zwei Läufe; die linke sichtbare Vorderbeinspur liegt dort ungefähr bei `x = 601…652`
- dieser Vergleich dient nur der statischen Montageposition; er beweist **keine** Near/Far-Z-Reihenfolge

## Schritt 4B–4E — erstes vollständiges Bein montiert und validiert

Die linke Front-Sheet-Kette ist jetzt als vollständige statische Godot-Kette montiert:

`FrontNear → Upper → LowerPivot → Lower → HoofPivot → Hoof`

### Texturquelle

Es wurden **keine Einzel-PNGs exportiert**. Alle drei Segmente verwenden `AtlasTexture` direkt aus dem unveränderten bestätigten Front-Sheet:

- Upper: Region `Rect2(183, 32, 361, 608)`
- Lower: Region `Rect2(208, 651, 171, 330)`
- Hoof: Region `Rect2(240, 1000, 222, 305)`
- Quell-Sheet SHA-256 bleibt `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`

### Bestätigte Godot-Transforms

`FrontNear`:

- Position im Rig-Root: `(155, -53)`
- Rotation: `0 rad`
- Scale: `(0.5, 0.5)`
- `z_index = 1` — vor dem Body

`Upper`:

- lokaler Offset: `(-19.75, 275.924)`
- Rotation: `0 rad`
- eigene Scale: `1` — erbt die `0.5` des FrontNear-Roots

`LowerPivot`:

- lokaler Offset unter Upper: `(-33.065, 274.582)`
- abgeleitet aus dem dokumentierten Upper-Bottom-Anker `(147.435, 578.582)` relativ zur Upper-Regionmitte

`Lower`:

- lokaler Offset unter LowerPivot: `(-3.209, 148.182)`
- damit liegt der dokumentierte Lower-Top-Anker `(88.709, 16.818)` auf dem Pivot

`HoofPivot`:

- lokaler Offset unter Lower: `(-21.145, 149.993)`
- abgeleitet aus dem dokumentierten Lower-Bottom-Anker `(64.355, 314.993)`

`Hoof`:

- lokaler Offset unter HoofPivot: `(67.359, 138.418)`
- damit liegt der dokumentierte Hoof-Top-Anker `(43.641, 14.082)` auf dem Pivot

Die Ankerüberlappung ist absichtlich leicht positiv; sie versteckt die künstlichen Schnittkanten ohne Bildbearbeitung.

### Near/Far-Ergebnis

Der kontrollierte Montagevergleich wurde mit drei Ansichten durchgeführt:

1. bestätigte Master-Pose
2. dieselbe linke Front-Kette **vor** dem Body
3. dieselbe Kette **hinter** dem Body

Nur die Variante **vor dem Body** reproduziert die sichtbare Schulter-/Beinform der Master-Pose. Hinter dem Body wird der relevante obere Beinbereich abgeschnitten.

Damit ist für das Front-Sheet bestätigt:

- **linke Sheet-Spalte = FrontNear**
- **rechte Sheet-Spalte = FrontFar** (durch die bestätigte Zweierstruktur des Front-Sheets logisch verbleibende Variante; noch nicht montiert)

Die Hind-Sheet-Near/Far-Zuordnung bleibt weiterhin offen, bis deren kontrollierter Montagevergleich erfolgt.

### Commits des Aufbaus

- `0b623c415d6a41b33b2d306d987de36b73d3a505` — neutrale erste Front-Kette festgelegt
- `531feb24ddad9a10772c680ec05fb91be17d90c1` — Upper angebunden
- `61b37bed4c69567b60d213e3384dc666dab803e4` — Lower angebunden
- `bd9142964778da6cc05df6682e05de070aa41087` — Hoof angebunden
- `757f910c99cb82b395bd450327d058c862bff39d` — linke Front-Kette als `FrontNear` bestätigt
- `b1b86e94d2c9f9e8d320bddbfc7142ca7e0e2639` — verbliebene Upper-Parent-Referenz nach Umbenennung korrigiert

### Technische Validierung

Nach der Parent-Korrektur wurde der Stand erneut vollständig geprüft:

- verifizierte Workflow-Basis: `efba8db681ad6ab575ebeced78f8e968fa6c9536`
- Godot 4.3 Headless Parse/Import: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `9971aceae4f80023ac630f36bbebd066eeefc6a4`
- erzeugtes Test-APK SHA-256: `5a8c519bdfe87fde09ba64b90f0975b81167549018b2468d112de017105493b5`

Die übrigen drei Beine sind weiterhin untexturiert. Es wurde keine Walk-Animation und keine Farm-Integration begonnen.

## Schritt 5A — FrontFar vollständig montiert

Die rechte Front-Sheet-Kette ist jetzt als zweites vollständiges Vorderbein montiert:

`FrontFar → Upper → LowerPivot → Lower → HoofPivot → Hoof`

### Texturquelle

Wie beim FrontNear-Bein werden **keine Einzel-PNGs exportiert**. Verwendet werden `AtlasTexture`-Regions direkt aus dem unveränderten Front-Sheet:

- Upper: `Rect2(715, 64, 274, 592)`
- Lower: `Rect2(767, 675, 143, 309)`
- Hoof: `Rect2(766, 1007, 220, 289)`
- Quell-Sheet SHA-256: `21003a4575973514be9f1508e828c0f90c2f0d12f3f519188b4e1b495eb96e8a`

### Bestätigte Godot-Transforms

`FrontFar`:

- Position im Rig-Root: `(247, -53)`
- Rotation: `0 rad`
- Scale: `(0.5, 0.5)`
- `z_index = -1` — hinter dem Body

`Upper`:

- lokaler Offset: `(28.522, 268.645)`
- Rotation: `0 rad`

`LowerPivot`:

- lokaler Offset unter Upper: `(-25.791, 269.543)`
- aus dem dokumentierten Upper-Bottom-Anker der rechten Front-Spalte abgeleitet

`Lower`:

- lokaler Offset: `(0.943, 138.502)`
- legt den dokumentierten Lower-Top-Anker auf `LowerPivot`

`HoofPivot`:

- lokaler Offset unter Lower: `(4.488, 140.352)`

`Hoof`:

- lokaler Offset: `(41.127, 131.459)`
- legt den dokumentierten Hoof-Top-Anker auf `HoofPivot`

### Montagevergleich

Ein kontrollierter Vergleich aus:

1. Master-Pose
2. Body + FrontNear + FrontFar

bestätigt für die statische Standpose:

- Fußhöhe stimmt mit der Master-Pose überein
- Beinlänge und seitlicher Versatz sind plausibel
- der obere Bereich von FrontFar verschwindet korrekt hinter dem Body
- keine zusätzliche Rotation oder Scale-Korrektur ist für die Standpose nötig

Preview-Commit:

- `8f663311cedbef7ec93a461d80d3c2a6e8306457`

Aufbau-Commits:

- `547c845e3ff65f3c0c12c5d9d9fd3de601e1c157` — FrontFar Upper
- `60c63545bbb73e64ae546bd703c82fca26e5d573` — FrontFar Lower
- `dc35fb7cec06f862fa79823ff0affe2e066d081b` — FrontFar Hoof

Damit sind beide Vorderbeine statisch vollständig montiert. Die beiden Hinterbeine bleiben weiterhin untexturiert.

## Nächster technischer Schritt

Vor dem ersten Hinterbein wird der Zwei-Vorderbein-Stand technisch validiert. Danach folgt **genau ein** Hinterbein als nächste 3-Segment-Kette; Near/Far des Hind-Sheets wird weiterhin nicht geraten.
