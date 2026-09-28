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

Technische Validierung des Zwei-Vorderbein-Stands:

- verifizierte Workflow-Basis: `ec658fb8e8f5f091407e5fc0055daa78b74cfdd1`
- Godot 4.3 Headless Parse/Import: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `eeb764fca324e009efe5fe4012c3d568106bfb28`
- Test-APK SHA-256: `94bc4edc898cc33dd102a0cfd272be823794468de2da4f93037b310be4b69710`

Aufbau-Commits:

- `547c845e3ff65f3c0c12c5d9d9fd3de601e1c157` — FrontFar Upper
- `60c63545bbb73e64ae546bd703c82fca26e5d573` — FrontFar Lower
- `dc35fb7cec06f862fa79823ff0affe2e066d081b` — FrontFar Hoof

Damit sind beide Vorderbeine statisch vollständig montiert. Die beiden Hinterbeine bleiben weiterhin untexturiert.

## Schritt 5B — HindNear vollständig montiert

Für das erste Hinterbein wurde zunächst neutral die **linke Hind-Sheet-Spalte** verwendet und erst nach Montagevergleich kanonisiert.

Kette:

`HindNear → Upper → LowerPivot → Lower → HoofPivot → Hoof`

### Texturquelle

Alle drei Segmente verwenden `AtlasTexture` direkt aus dem unveränderten Hind-Sheet:

- Upper: `Rect2(164, 53, 368, 519)`
- Lower: `Rect2(174, 553, 212, 353)`
- Hoof: `Rect2(149, 921, 253, 405)`
- Hind-Sheet SHA-256: `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3`

Keine Einzel-PNGs wurden erzeugt und kein Quellasset verändert.

### Bestätigte Godot-Transforms

`HindNear`:

- Position im Rig-Root: `(-446, -74)`
- Rotation: `0 rad`
- Scale: `(0.5, 0.5)`
- `z_index = 1` — vor dem Body

`Upper`:

- lokaler Offset: `(-20.816, 234.353)`
- Rotation: `0 rad`

`LowerPivot`:

- lokaler Offset: `(-36.101, 235.597)`

`Lower`:

- lokaler Offset: `(-13.638, 163.241)`

`HoofPivot`:

- lokaler Offset: `(-34.745, 160.511)`

`Hoof`:

- lokaler Offset: `(49.841, 181.998)`

Die Werte sind direkt aus den dokumentierten Top-/Bottom-Ankern der linken Hind-Spalte abgeleitet; die Root-Position wurde gegen Fußhöhe und Master-Silhouette kalibriert.

### Near/Far-Ergebnis

Der kontrollierte Vergleich zeigte dieselbe Kette:

1. vor dem Body
2. hinter dem Body

Nur **vor dem Body** bleibt die sichtbare äußere Hinterhand-/Oberschenkel-Silhouette der Master-Pose erhalten. Hinter dem Body wird der obere Beinbereich zu stark verdeckt.

Damit ist für das Hind-Sheet bestätigt:

- **linke Sheet-Spalte = HindNear**
- **rechte Sheet-Spalte = HindFar** (noch nicht montiert)

Die Fußposition der linken Kette trifft die Master-Pose ausreichend genau; keine zusätzliche Root-, Scale- oder Rotationskorrektur wurde nötig.

Aufbau-/Vergleichs-Commits:

- `df117b20506085e454b3895e981cb5f7c392bdbd` — HindLeftColumn Upper
- `f64db9f829fa5e351e23e0cba10817261d45b904` — Lower
- `9ee4c7f2297ab96c21794abd597b52544719455e` — Hoof
- `22ba19c54613815f312548608bb86e899b353968` — Layering-Vorschau
- `84a8957cf2c1c644d6ba46aab47bfbfcab59f406` — als `HindNear` bestätigt
- `6e282810862492afb8067ba3b3b20539b660f65c` — Upper-Parent-Pfad nach Umbenennung korrigiert

Technische Validierung des Drei-Bein-Stands:

- verifizierte Workflow-Basis: `4d463d08ca5014a068e076d6b1eccf16ab9c28c7`
- Godot 4.3 Headless Parse/Import: **success**
- Android Debug Export: **success**
- Test-APK SHA-256: `8b13955688527e79fb3483847694476cbc3c9b825d64a36f142bfa99e44c34f9`

Damit sind drei von vier Beinen vollständig montiert. `HindFar` bleibt noch untexturiert.

## Schritt 5C — HindFar vollständig montiert

Die rechte Hind-Sheet-Spalte ist als letztes Bein montiert:

`HindFar → Upper → LowerPivot → Lower → HoofPivot → Hoof`

### Texturquelle

Alle drei Segmente verwenden `AtlasTexture` direkt aus dem unveränderten Hind-Sheet:

- Upper: `Rect2(646, 65, 353, 515)`
- Lower: `Rect2(764, 553, 226, 356)`
- Hoof: `Rect2(751, 916, 262, 407)`
- Hind-Sheet SHA-256: `d24aba84e51075cdd1e5c83d12432d2d7a1731c8c9bbb522c2db731bc04744e3`

Keine Einzel-PNGs wurden erzeugt und kein Quellasset verändert.

### Bestätigte Godot-Transforms

`HindFar`:

- Position im Rig-Root: `(-262, -77)`
- Rotation: `0 rad`
- Scale: `(0.5, 0.5)`
- `z_index = -1` — hinter dem Body

`Upper`:

- lokaler Offset: `(32.071, 233.122)`
- Rotation: `0 rad`

`LowerPivot`:

- finaler lokaler Offset: `(7.159, 219.652)`
- ursprünglicher Ankerwert war `(7.159, 235.652)`
- um `16` lokale Pixel nach oben verschoben, damit Upper und Lower sichtbar überlappen statt eine transparente Schnittlücke zu erzeugen

`Lower`:

- lokaler Offset: `(38.005, 165.058)`

`HoofPivot`:

- lokaler Offset: `(31.74, 160.626)`

`Hoof`:

- lokaler Offset: `(-49.206, 182.544)`

Zur Kompensation der `LowerPivot`-Überlappung wurde der `HindFar`-Root von `y = -85` auf `y = -77` verschoben. Dadurch bleiben Lower, Hoof und Fußpunkt global unverändert, während nur das Upper tiefer über den nächsten Abschnitt greift.

### Vier-Bein-Vergleich

Der vollständige statische Vergleich gegen die Master-Pose bestätigt:

- alle vier Hufe liegen auf plausibler Master-Fußhöhe
- FrontNear / HindNear liegen vor dem Body
- FrontFar / HindFar liegen hinter dem Body
- die Seitwärtsabstände der vier Beine entsprechen der Master-Pose ausreichend genau
- nach dem HindFar-Overlap-Fix ist keine transparente Lücke mehr sichtbar
- keine weitere Rotation oder Scale-Korrektur ist für Schritt 5 nötig

Finaler Preview-Commit:

- `7115f64f856977cfa232bdf9dfb27e646e6d2e1f`

Aufbau-/Korrektur-Commits:

- `872cc4186a535f630745081de71ebeb0a53c12f5` — HindFar Upper
- `66344e493cfdde4cd4bb5c12db8c9f5532c10efd` — HindFar Lower
- `c9e1d114addf9a4c20659783b84fcc64e3fd51e5` — HindFar Hoof
- `a697cf5f294ee2af6ce4a431a05ae8239d7e046e` — Upper/Lower-Overlap korrigiert

### Finale technische Validierung für Schritt 5

- verifizierte Workflow-Basis: `a6706e83e95bda12d81ac72d09ffcdd2e3bf1c22`
- Godot 4.3 Headless Parse/Import: **success**
- Android Debug Export: **success**
- Validierungs-Commit: `04c9a06b69147845727d47a58b3c12c7cb50aeaa`
- Test-APK SHA-256: `eda1d08a2f3fad3011109d0322d4c122c035b4d4e9ff7c143063656dace7fd0c`

Damit ist **Schritt 5 abgeschlossen**: alle vier Beine und alle zwölf Beinsegmente sind statisch montiert.

## Nächster technischer Schritt

**Schritt 6:** vollständige statische Pferdefigur gegen die Master-Pose prüfen. Dabei dürfen ausschließlich Node-Transforms/Pivots korrigiert werden. Keine Asset-Neugenerierung und noch keine Animation.


## Schritt 10 — erster bewusst billiger Walk-Test

Abgeschlossen am 2026-09-27.

### Ausgangsbasis

Schritt 10 startete direkt vom vollständig bereinigten Step-9-HEAD:

- Ausgangs-HEAD: `5026bc227da6dde89a8097226fe0a23988818160`
- alle vier Beine waren weiterhin in ihren bestätigten statischen Positionen
- sämtliche statischen Root-, LowerPivot-, HoofPivot-, Scale- und Layerwerte blieben unverändert
- bestehende Jaw-, Head- und Tail-Animationen blieben unverändert

Für den Walk wurde ein eigener dritter AnimationPlayer ergänzt:

- Node: `WalkAnimationPlayer`
- Animation: `walk_test`
- Autoplay: aktiv
- Loop: aktiv
- Länge: `1.2 s`
- eigene `RESET`-Animation
- kein IK
- keine Physik
- keine neue Textur
- keine Segmentspiegelung
- keine Farm-Integration

### Mini-Schritt 10A — nur Bein-Roots / Upper-Swing

Erster Runtime-Commit:

- `684642a7e87ba86d9ba854a9484a4bf08008c078` — `Add walk root swing test`

Die vier Bein-Roots dienen als proximale/Upper-Pivots. Diagonale Paare bewegen sich grob gegeneinander, bewusst leicht zeitversetzt.

`FrontNear:rotation`:

- Zeiten: `0.00 / 0.28 / 0.58 / 0.88 / 1.20 s`
- Winkel: `0° / +6° / 0° / -5° / 0°`
- rad: `0 / 0.10472 / 0 / -0.0872665 / 0`

`HindFar:rotation`:

- Zeiten: `0.00 / 0.34 / 0.64 / 0.94 / 1.20 s`
- Winkel: `0° / +5° / 0° / -4° / 0°`
- rad: `0 / 0.0872665 / 0 / -0.0698132 / 0`

`FrontFar:rotation`:

- Zeiten: `0.00 / 0.30 / 0.60 / 0.90 / 1.20 s`
- Winkel: `0° / -5° / 0° / +6° / 0°`
- rad: `0 / -0.0872665 / 0 / 0.10472 / 0`

`HindNear:rotation`:

- Zeiten: `0.00 / 0.36 / 0.66 / 0.96 / 1.20 s`
- Winkel: `0° / -4° / 0° / +5° / 0°`
- rad: `0 / -0.0698132 / 0 / 0.0872665 / 0`

Technische Prüfung dieses Mini-Schritts:

- Godot-Run `36351220180`: **success**
- Android-Run `36351220066`: **success**
- Preview-Workflow-Commit: `a81a01b810613a0024bbbee7f147b3aa52fce608`
- erster Root-Preview-Commit: `3a044616e50e5bc8f53a03a9ed6c3872032079b3`

Ergebnis: Die vier Root-Pivots funktionieren als primitive Walk-Basis. Kein Gelenk riss auf, aber die Ketten wirkten erwartbar noch sehr steif.

### Mini-Schritt 10B — LowerPivot-Gegenbewegung

Runtime-Commit:

- `68dfdc73268568a36875344e45f911cf1aac7d56` — `Add lower leg counter swing`

Die LowerPivots rotieren gegen die jeweilige Root-Bewegung:

`FrontNear/Upper/LowerPivot:rotation`:

- Zeiten wie FrontNear Root
- Winkel: `0° / -8° / 0° / +6° / 0°`
- rad: `0 / -0.139626 / 0 / 0.10472 / 0`

`HindFar/Upper/LowerPivot:rotation`:

- Zeiten wie HindFar Root
- Winkel: `0° / -6° / 0° / +5° / 0°`
- rad: `0 / -0.10472 / 0 / 0.0872665 / 0`

`FrontFar/Upper/LowerPivot:rotation`:

- Zeiten wie FrontFar Root
- Winkel: `0° / +6° / 0° / -8° / 0°`
- rad: `0 / 0.10472 / 0 / -0.139626 / 0`

`HindNear/Upper/LowerPivot:rotation`:

- Zeiten wie HindNear Root
- Winkel: `0° / +5° / 0° / -6° / 0°`
- rad: `0 / 0.0872665 / 0 / -0.10472 / 0`

Prüfung:

- Godot-Run `36351413903`: **success**
- Android-Run `36351413823`: **success**
- Preview-Run `36351413951`: **success**
- Preview-Ergebnis: `8b4d492ba4ba8b5d3983d5b937ecf84154c0158f`

Ergebnis: Die Lower-Gegenbewegung reduziert die reine „starre Stange“-Optik, ohne Segmentlücken zu erzeugen. Der Bereich wurde ohne Korrektur übernommen.

### Mini-Schritt 10C — HoofPivot-Gegenrotation

Runtime-Commit:

- `a659d41dfe39cc46cf40955047225db249a852a6` — `Add hoof counter rotation`

Die Hufrotation bleibt absichtlich kleiner als Root und Lower:

`FrontNear/.../HoofPivot:rotation`:

- Zeiten wie FrontNear Root
- Winkel: `0° / +4° / 0° / -3° / 0°`
- rad: `0 / 0.0698132 / 0 / -0.0523599 / 0`

`HindFar/.../HoofPivot:rotation`:

- Zeiten wie HindFar Root
- Winkel: `0° / +3° / 0° / -2° / 0°`
- rad: `0 / 0.0523599 / 0 / -0.0349066 / 0`

`FrontFar/.../HoofPivot:rotation`:

- Zeiten wie FrontFar Root
- Winkel: `0° / -3° / 0° / +4° / 0°`
- rad: `0 / -0.0523599 / 0 / 0.0698132 / 0`

`HindNear/.../HoofPivot:rotation`:

- Zeiten wie HindNear Root
- Winkel: `0° / -2° / 0° / +3° / 0°`
- rad: `0 / -0.0349066 / 0 / 0.0523599 / 0`

Prüfung:

- Godot-Run `36351496241`: **success**
- Android-Run `36351496218`: **success**
- Preview-Run `36351496246`: **success**
- Preview-Ergebnis: `d362cbf3372277d75756a6fd1e7e0103c08259d2`

Ergebnis: Die Hufe wirken nicht mehr vollständig starr an den Lower-Segmenten, bleiben aber deutlich im absichtlich billigen Cutout-Stil.

### Mini-Schritt 10D — kleiner Torso-Bob

Damit der Walk nicht ausschließlich aus Beinrotation besteht, wurde ein sehr kleiner vertikaler Bob ergänzt.

Wichtig: **Der Rig-Root selbst wird nicht animiert.**

Dadurch bleibt die spätere Farm-/Perspektivpositionierung frei von einem konkurrierenden Walk-Positionstrack.

Stattdessen bewegen sich gemeinsam:

- `Body:position`
- `HeadPivot:position`
- `TailPivot:position`

Zeiten für alle drei:

- `0.00 / 0.30 / 0.60 / 0.90 / 1.20 s`

Gemeinsame Y-Deltas gegenüber der bestätigten Ruheposition:

- `0 px / -3 px / +2 px / -2 px / 0 px`

Body:

- `(-76.5412, -101.756)`
- `(-76.5412, -104.756)`
- `(-76.5412, -99.756)`
- `(-76.5412, -103.756)`
- `(-76.5412, -101.756)`

HeadPivot:

- `(321.171, -194.253)`
- `(321.171, -197.253)`
- `(321.171, -192.253)`
- `(321.171, -196.253)`
- `(321.171, -194.253)`

TailPivot:

- `(-449, -198)`
- `(-449, -201)`
- `(-449, -196)`
- `(-449, -200)`
- `(-449, -198)`

Runtime-Commit:

- `bfa96169aae7e1b852a5e0c6133b8e162a8a96d1` — `Add subtle torso bob to walk test`

Technische Runtime-Prüfung dieses Standes:

- Godot-Run `36351647437`: **success**
- Android-Run `36351647460`: **success**

### Temporärer Preview-Parser-Fehler — bewusst dokumentiert

Vor dem Torso-Bob wurde das temporäre Preview-Werkzeug separat um Positions-Tracks erweitert:

- `d10aa0f2123cd1bbb19cce0dcbbd3d46c94b7f18` — `Extend walk preview for position tracks`
- Verifikations-Preview: `6f3015a0824818b2f4c8eed7271421d155914d75`

Beim ersten Preview des Torso-Bobs schlug nur das Prüfwerkzeug fehl:

- fehlgeschlagener Preview-Run: `36351647438`
- Godot-Headless innerhalb dieses Runs war **success**
- Fehler: Der Python-Regex für `Vector2(...)` war eine Ebene zu stark escaped und erkannte deshalb null Positionswerte

Es wurde **keine Runtime-Änderung zurückgerollt oder verändert**.

Kleinster möglicher Prüfwerkzeug-Fix:

- `d0d3d261c032d7adcef1a55393906034172f6185` — `Fix walk preview Vector2 parser`

Danach:

- korrigierter Preview-Run: `36351702096` — **success**
- finaler Preview-Ergebnis-Commit: `9b74b73e3229c596aeb13d15c43e8538da06c099`

Die finale Preview bestätigt:

- alle Gelenke bleiben geschlossen
- keine neue transparente Segmentlücke
- Root-, Lower- und Hoof-Rotationen sind als simple Puppenbewegung lesbar
- der Torso-Bob bleibt klein
- kein Rig-Root-Gleiten wurde eingebaut
- keine Winkel-/Timing-Korrektur war nach der finalen visuellen Prüfung nötig

### Finale Step-10-Struktur

`WalkAnimationPlayer / walk_test` enthält exakt **15 Tracks**:

- 4 × Bein-Root/Upper-Rotation
- 4 × LowerPivot-Rotation
- 4 × HoofPivot-Rotation
- 3 × Position für Body / HeadPivot / TailPivot

Die separate `RESET`-Animation enthält dieselben 15 Eigenschaften mit ihren bestätigten Ruhewerten.

### Unveränderte statische Rig-Werte

Schritt 10 verändert **keinen** der bestätigten statischen Beinwerte.

Insbesondere unverändert:

- alle vier Bein-Root-Positionen
- alle vier Bein-Root-Scales
- Near/Far-`z_index`
- alle vier Upper-Offsets
- alle vier LowerPivot-Positionen
- alle vier Lower-Offsets
- alle vier HoofPivot-Positionen
- alle vier Hoof-Offsets
- HindFar-Sonderwert `LowerPivot = (7.159, 219.652)`
- HindFar Root `(-262, -77)`
- alle AtlasTexture-Regions
- beide Segment-Sheet-Dateien und ihre SHA-256-Werte

### Finale technische Validierung

Finaler Workflow:

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
- `WalkAnimationPlayer` vorhanden
- Autoplay `walk_test`
- Loop aktiv
- Länge `1.2 s`
- Walk-Track-Anzahl: `15`
- RESET-Track-Anzahl: `15`
- alle Root-/Lower-/Hoof-Zeiten und Rotationswerte bestätigt
- alle drei Torso-Positions-Tracks bestätigt
- statische Standpose-Transforms weiterhin bestätigt
- Android Debug Export: **success**
- APK SHA-256: `1f8359f2f6c460b2e3e0fce354148a4ac9b09d8633b83e6468eaba7f7f60e517`

Damit ist **Schritt 10 abgeschlossen**.

## Aktuell nächster technischer Schritt

**Schritt 11:** Erst jetzt darf das bisher starre Master-Pferd in der Farm durch das Cutout-Rig ersetzt werden.

Dabei zwingend erhalten:

- bestehende 1/Z-Perspektivskalierung
- Huf-/Bodenanker
- Y-basierte Z-Sortierung
- Hindernisgrenzen
- Touch-/Drag-Steuerung
- RIGHT = Original / LEFT = gesamtes Rig horizontal gespiegelt
- extreme Kameranähe

Keine dieser Farm-Grundlagen darf für die Rig-Integration neu erfunden werden.


## Step 12 — Gerätetest überschreibt statische Hinterbein-Abnahme

Die in Schritt 5/6 dokumentierten Hinterbeinwerte bleiben als **historischer Aufbau- und statischer Vergleichsstand** erhalten. Der echte Android-Gerätetest hat jedoch zwei Punkte sichtbar widerlegt; für den aktuellen Runtime-Canon gelten deshalb ab Step 12 folgende Overrides:

- `HindNear`: Root-Position bleibt `(-446, -74)`, aber Root-Scale ist jetzt `(-0.5, 0.5)` statt `(0.5, 0.5)`. Dadurch wird die komplette bestehende Segmentkette anatomisch korrekt ausgerichtet, ohne ein Quellasset zu ändern. Commit: `bd81055911cb30fd86b2eb079502a0126b4de302`.
- Die drei `HindNear`-Walk-Rotationstracks wurden beim Mirror in der Drehrichtung angepasst; der spätere stärkere Walk überschreibt diese Werte als Teil des gemeinsamen Step-12-Zyklus.
- `HindFar`: Root-Position ist jetzt `(-330, -77)` statt `(-262, -77)`; dadurch liegt das äußere Hinterbein näher unter der Hinterhand. Commit: `26ba13c40a27b603f0370f82f5a77759365a6cad`.
- Layering-Canon: `TailPivot z=-2`, `HindFar z=-1`, Body Basis-Z `0`, `HindNear z=1`. Commit: `ccd15bfa5d73af62003e90f71fa42d4215c2146b`.
- Die Segment-Atlanten, Crops, Pivots und Quell-PNGs selbst bleiben unverändert.
- Der bestehende 1,2-s-Walk wurde in `c2b24d34855bad9995011f74153f5ec8d1051a76` deutlich verstärkt und auf klarere Viertelphasen verteilt; `f3eb8ce362bf413b0d22c979844fbee39473f4ca` koppelt Playback-Speed und leichte Amplitudenvariation an die tatsächliche Drag-Geschwindigkeit.

Bei Widersprüchen zwischen älteren Schritt-5/6-Werten und diesem Abschnitt ist für die aktuelle Runtime **dieser Step-12-Override maßgeblich**.


## Step-12 Recovery — vorheriger Override VERWORFEN

Der unmittelbar vorherige Abschnitt „Step 12 — Gerätetest überschreibt statische Hinterbein-Abnahme“ beschreibt einen **fehlgeschlagenen Zwischenstand** und ist nicht mehr gültiger Runtime-Canon.

Der echte Fold-Test dieses Zwischenstands zeigte, dass beide Hinterbeine visuell falsch wurden. Deshalb gilt wieder:

- `HindNear`: Position `(-446, -74)`, Scale `(0.5, 0.5)`, `z_index = 1`
- `HindFar`: Position `(-262, -77)`, Scale `(0.5, 0.5)`, `z_index = -1`
- `TailPivot`: wieder `z_index = -1`
- kompletter Walk wieder exakt Step 11
- keine geschwindigkeitsabhängige Walk-Amplitudenlogik
- Segment-Atlanten, Pivots und alle Quellassets unverändert

Recovery-Commit der Rig-Datei:
- `7f3b243753080d8ebc26e9c5accf12820bb6793d`

Validierter Recovery-Scene-Blob:
- `0c94231e6e037d2ff32f9a70fe69f459dcc870ac`

Einzige gegenüber Step 11 erhaltene Änderung im Rig:
- Kopfposition/-überdeckung aus 12A/12B.

Bei jedem Widerspruch mit dem verworfenen Step-12-Override ist **dieser Recovery-Abschnitt maßgeblich**.
