# Farm / Cutout-Rig — Schritt 11

## Ausgangsstand und Audit (11A)

GitHub `main` direkt geprüft: `d83694ccc2be05df037a50b75cd09e18afbb2e90`.
Dies entspricht dem Übergabeanker. Die letzten fünf Commits entfernen ausschließlich
die temporären Step-10-Prüfdateien. Es gibt keinen neueren Farm-Umbau.

Vollständig gelesen: `MASTER_SPEC.md`, `HORSE_LEG_RIG.md`,
`horse_cutout_rig.tscn`, `main.tscn`, `main.gd`, außerdem `PERSPECTIVE_MODEL.md`,
Asset-/Recovery-/Source-Audit-Doku, Materializer und bestehende Build-Workflows.
Keine AGENTS.md im Repository. Die Farm referenziert kein weiteres Script oder Helper.
Historische Aussagen in Asset-/Source-Dokumenten beschreiben ältere Meilensteine;
der aktuelle Dateibaum und der erfolgreiche Materializer bestätigen alle Assets.

### Tatsächliche Integrationspunkte

| Frage | Verifizierter Stand vor Integration |
| --- | --- |
| Sichtbares Pferd | `Main/HorseRoot/HorseMaster`, Typ `Sprite2D` |
| Bewegter Parent | `Main/HorseRoot`, Typ `Node2D`, Ursprung ist der projizierte Bodenpunkt |
| Script-Referenzen | `$Background`, `$HorseRoot`, `$HorseRoot/HorseMaster` in `main.gd` |
| Position | ausschließlich `horse_root.position` in `_apply_perspective()` |
| Perspektiv-Scale | `horse_root.scale = Vector2.ONE * visual_scale` |
| Richtungswechsel | `set_horse_facing_right()` setzt `horse_master.flip_h`; `_move_horse_to()` entscheidet anhand X-Differenz > 1 px |
| Welt-Z | `horse_root.z_index = int(round(horse_depth_t * 100.0))` |
| Bodenanker | Texturmitte in X; Y = Texturhöhe × `1055/1086`; nicht Sprite-Mittelpunkt |
| Runtime-Mastergröße | tatsächlich **1024 × 768**; ursprünglicher Referenzraum **1448 × 1086** |
| Sprite-Offset | `(0, 768/2 - 768*1055/1086)` = `(0, -362.077348...)`; Sprite-Position `(0,0)`, centered true |
| Sichtbare Kalibrierhöhe | `768 * 1039/1086` = `734.762430...` Runtime-Pixel |
| Kollision | kein CollisionObject, keine Physics-/Area-Nodes; Grenzen rein mathematisch in `main.gd` |
| Sprite-spezifische Zugriffe | Laden der Pferdetextur in `_ready()`, `texture.get_size()`/centered/offset in `_configure_horse_foot_anchor()`, `flip_h` und `texture.get_height()` in `_apply_perspective()` |

### Erhaltene Farm-Systeme

- Touch-Press, ScreenDrag, linker Mausklick und MouseMotion während Drag führen
  über `_move_horse_to()` zu `set_horse_position()`.
- X wird auf `[0, viewport_width]` begrenzt, Eingabe-Y auf `[0.565h, 0.985h]`.
- Zustand bleibt `horse_x_ratio` / `horse_depth_t`, inklusive Resize/Fold-Erhalt.
- `Z = lerp(12.0, 1.40, depth_t)`, Gain `12/max(Z,0.01)`.
- Horizont `0.405h`, hinterer Hufpunkt `0.565h`, Pferd/Kamera `1.65/1.70`.
- Bei Nahdistanz darf der Hufpunkt unterhalb des Viewports liegen.
- Ortsabhängige rückwärtige Hindernisgrenze bleibt in
  `_minimum_projected_foot_y_ratio_for_x()` / `_minimum_depth_t_for_x()`:
  außen 0.600, Hindernisse 0.585, offener Hof 0.565; alle X-Grenzen bleiben gleich.
- Die als Y-Sortierung bezeichnete vorhandene Logik ist technisch ein monotoner
  depth_t-Z-Wert 0–100. Kein `y_sort_enabled` und keine einzeln sortierbaren
  Farmobjekte: Scheune, Heu, Zaun und Unterstand sind im Background enthalten.
  Daher keine erfundene Objektverdeckung einbauen.

### Rig und Integrationsplan

`horse_cutout_rig.tscn` ist vollständig und scriptfrei. 3 AnimationPlayer,
Jaw/Head, Tail und Walk (15 Tracks + 15 RESET-Tracks); der Rig-Root wird nicht animiert.
Alle internen Transforms, Atlas-Regions, Layer und Animationen bleiben unverändert.

Geplante schrittweise Hierarchie:

`HorseRoot` (bestehende Weltposition/Perspektive/Z)
→ `HorseVisual` (Ganzrig-Flip)
→ `RigSpace` (fester Referenzraum-Faktor)
→ `HorseCutoutRig` (lokale Bodenanker-Verschiebung).

11B ergänzt diese Instanz zunächst unsichtbar parallel zum unveränderten Master.
11C misst die tatsächlichen Hufunterkanten im Stand und setzt ausschließlich den
Rig-Offset; bisheriger Master-Referenzanker entspricht Y=512 im Rig-Referenzraum.
11D bestimmt separat den festen Größenfaktor; Ausgangskandidat 1024/1448 = 768/1086.
11E überträgt Flip auf `HorseVisual`, ohne den positiven Perspektivscale zu überschreiben.
Erst 11F entfernt das sichtbare Master-Sprite samt überflüssigen Sprite-Zugriffen.
Eine Textur als unsichtbarer Runtime-Helfer ist nicht nötig: die bisherige gemessene
Kalibrierhöhe kann als feste Zahl aus den unveränderten Canon-Maßen erhalten bleiben.

### Asset-Integrität vor jeglicher Runtime-Änderung

`python tools/materialize_verified_rig_assets.py`: **PASS**, alle acht Dateien
**UNCHANGED**, exakte Source-Bytes und gepinnte Recovery-Hashes bestätigt.
Kein Aufruf des re-encodierenden Runtime-Extractors.

Zusätzlich gemessene SHA-256:

- Master (1024×768): `6738b40a2ba94d084c2fbb17b1eaf08755d19d5ef2f534ceec21b384f2db6dab`
- Tagfarm (1536×864): `70dc5165483fcb02ca31a08e165ecffe63474db4f6b62b2b6d67e5ef5f50d8bd`
- Nachtfarm (1536×864): `c60542efdbdcc792c3f61ae7e8e0f6cd13163b5aff1b86aa6985436045f0bc4d`
- HeadUpper: `dd753547d79e2d3a817726815543ca565319980fbbb8f9d4f8d7e98c3eb617bd`
- Jaw: `b50d5a41a80e2faf483849a21082f9c788a76d19c556b56e84c585c26ffb9152`

Übrige Pins stehen unverändert in `tools/materialize_verified_rig_assets.py`.

## Fortschritt

- 11A Audit abgeschlossen und auf `main`: `a0b15b1282ebcd788ea1df17bd3e474947316ad8`.
- 11B: `HorseRoot/HorseVisual/RigSpace/HorseCutoutRig` als echte PackedScene-Instanz
  ergänzt. `HorseVisual.visible = false` für den parallelen Aufbau; Master bleibt
  sichtbar, `main.gd` unverändert. Alle drei Player behalten ihr Autoplay.
- Nächster Mini-Schritt: Godot-Headless-Prüfung, erst danach Bodenanker.

### Arbeitsumgebung

Git-Clone/Fetch funktioniert. Direkter Git-Push hat keine lokalen HTTPS-Zugangsdaten;
Schreibzugriffe erfolgen deshalb über den verbundenen GitHub-Connector, mit
anschließender lokaler Synchronisierung vom verifizierten `main`. Godot 4.3 wurde
für lokale Headless-Prüfungen heruntergeladen. Dies ist kein Runtime-Problem.

## 11B — Prüfung der parallelen Instanz

- Instanz-Commit: `513b1ea5ba3f64d8dce23f8fd26285879321e9e3`.
- Lokales Godot **4.3.stable.official.77dcf97d8**, Editor-Import: **PASS**.
- Anschließend reale `main.tscn` headless gestartet, `--quit-after 3`: **PASS**, keine Script-/Scene-Fehler.
- Noch keine Änderung an Anchor, Scale, Flip oder `main.gd`.
- Lokaler Screenshot-Setupversuch (`apt-get update` für Xvfb) scheiterte an
  Container-Rechten für setgroups/setuid. Keine Runtime-Ursache; keine Rechteänderung
  oder Eskalation. Gerenderte Godot-Screenshots werden über einen temporären
  GitHub-Actions-Workflow mit virtuellem Display erzeugt. Lokale Headless-Tests
  bleiben möglich. Automatische Godot-Importcaches werden nicht versioniert.

## 11C — Messwerkzeug

Temporär `tools/measure_farm_rig.py` ergänzt: liest echte TSCN-Transforms,
Atlas-Regions und Original-Alpha. Schwellwert alpha >= 16 wie beim bestätigten
Segment-Audit; misst Pixelkanten im statischen, unskalierten Rig-Raum.
Keine Bilddatei wird geschrieben. Erst nach Speicherung dieses Werkzeugs wird
die Messung ausgeführt und der Bodenanker in einem eigenen Commit gesetzt.

### Messung und Bodenanker (11C)

Messwerkzeug-Commit: `bbade464d5cf71784b585ac014f0e62df7196f60`, Ausführung **PASS**.
Statische robuste Hufunterkanten im Rig-Raum:

| Huf | Y |
| --- | ---: |
| FrontNear | 516.7995 |
| HindNear | 515.1000 |
| HindFar | 505.2510 |
| FrontFar | 493.5005 |

Tiefster Standkontakt ist FrontNear. Neuer Instanz-Offset ausschließlich
`HorseCutoutRig.position = (0, -516.7995)`. Dadurch landet die tiefste Hufkante
auf `(x, 0)` innerhalb des Bodencontainers. Die bereits bestätigten unterschiedlichen
Hufhöhen bleiben unangetastet. Alter Master-Anker im Referenzraum wäre Y=512;
dieser wurde wegen des gemessenen 4.7995-px-Unterschieds nicht blind übernommen.

Rig-Oberkante alpha >= 16: Y=-530.338792; statische sichtbare Höhe 1047.138292.
Die Original-TSCN hat SHA-256 `328edf3d34090b08f4e729c690f04c36ad3f69f4d9d6813145bf73f9315cf96e`.
Noch kein Scale-/Flip-Wechsel; Master weiter sichtbar. Visueller Anchor-Vergleich
folgt vor der separaten Größenanpassung.

Remote-CI der 11B-Instanz zusätzlich bestätigt: Godot-Run `36352833000` **success**,
Android-Run `36352833014` **success**.


## 11D — Perspektiv-Basisscale

Die bestehende 1/Z-Perspektive bleibt vollständig auf `HorseRoot.scale`. Für den
intern im 1448×1086-Referenzraum montierten Cutout ist nur ein fester,
tiefenunabhängiger Integrationsfaktor auf `RigSpace` nötig.

Berechnung gegen die bereits kalibrierte sichtbare Masterhöhe:

- bisherige Runtime-Masterhöhe: `768 px`
- bestehende sichtbare Kalibrierhöhe: `768 × 1039 / 1086 = 734.762430939 px`
- gemessene Cutout-Höhe vom tiefsten Hufkontakt bis zur robusten Alpha-Oberkante:
  `1047.138292 px`
- daraus: `734.762430939 / 1047.138292 = 0.7016861446`
- gespeicherter Integrationsfaktor: `RigSpace.scale = (0.701686, 0.701686)`

Mit der gespeicherten Rundung ergibt die statische Cutout-Höhe `734.7622795 px`;
die Abweichung zur bisherigen Kalibrierhöhe beträgt nur rund `0.00015 px` vor dem
eigentlichen Perspektivscale. Damit bleibt die Farm-Zielhöhe bei jeder Tiefe
praktisch identisch, ohne die Perspektivformel oder einen Animationstrack anzufassen.

Der reine Referenzraum-Faktor `768/1086 = 0.7071823204` wurde bewusst **nicht**
blind verwendet: das montierte Cutout misst robust ca. 8.14 Referenzpixel mehr als
die alte sichtbare Master-Kalibrierhöhe. Der finale Faktor gleicht genau diese
sichtbare Höhe aus.

Weiterhin unverändert in diesem Mini-Schritt:

- `HorseVisual.visible = false` — Master bleibt noch die sichtbare Runtime-Referenz
- `HorseRoot.scale` und die komplette 1/Z-Formel
- Bodenanker-Offset `(0, -516.7995)`
- LEFT/RIGHT-Logik
- `scripts/main.gd`
- alle Rig-Transforms und Animationen

Nächster Prüfpunkt: visueller Alt-vs-Cutout-Vergleich bei ferner, mittlerer und sehr
naher Tiefe; erst nach erfolgreichem Größenvergleich folgt der Ganzrig-Flip.


### Temporärer visueller Größenvergleich (11D)

Für die vorgeschriebene Sichtprüfung vor dem Flip wurde ein temporäres, rein lesendes
Preview-Werkzeug ergänzt. Es rendert aus den echten TSCN-Transforms und unveränderten
Assets drei Tiefen (`depth_t = 0 / 0.5 / 1`) jeweils als alten Master, Cutout und
Überlagerung bei Fold-Testgröße `1536×1384`. Die Farm-Projektionsformel wird dabei
mit den unveränderten Canon-Konstanten ausgewertet. Das Werkzeug schreibt nur unter
`debug/`; Runtime-Dateien und Assets werden nicht verändert.


### Ergebnis des 11D-Größenvergleichs

Preview-Workflow-Commit: `e2486a9e1abe33bbf9cc1f9b43ed15dd1e5108f6`.
Preview-Run: `36353521554` — **success**.
Ergebnis-Commit: `7e9960e59b0fb7ed021fa7dc7d0712fa5dca504b`.

Geprüft wurden FAR (`depth_t=0`), MID (`0.5`) und NEAR (`1.0`) bei
`1536×1384`. Die berechneten Zielhöhen/äußeren HorseRoot-Scales waren:

- FAR: `214.927059 px`, Scale `0.292512314`
- MID: `384.943986 px`, Scale `0.523902652`
- NEAR: `1842.231933 px`, Scale `2.507248405`

Der direkte Master/Cutout/Overlay-Vergleich bestätigt den Integrationsfaktor
`0.701686`: die vertikale Gesamtgröße folgt in allen drei Tiefen der bisherigen
Farm-Kalibrierung, der gemessene Hufkontakt bleibt auf demselben projizierten
Bodenpunkt und die extreme Nahansicht schneidet den Unterkörper wie zuvor am
Viewport ab. Sichtbare Konturabweichungen sind die erwarteten Segment-/Cutout-Formen,
kein Perspektiv- oder Scale-Fehler. **Keine weitere Scale-Korrektur erforderlich.**

Damit ist 11D abgeschlossen. Nächster isolierter Runtime-Schritt: Ganzrig-Flip auf
`HorseVisual`; das alte sichtbare Master-Sprite bleibt dabei noch als Referenz erhalten.


## 11E — Ganzrig-Flip

Die bestehende Richtungsentscheidung in `_move_horse_to()` bleibt unverändert.
`set_horse_facing_right()` spiegelt jetzt zusätzlich ausschließlich den äußeren
`HorseVisual`-Container:

- RIGHT → `HorseVisual.scale = (1, 1)`
- LEFT → `HorseVisual.scale = (-1, 1)`

Damit werden Body, Kopf, Jaw, Schweif und alle vier vollständigen Beinketten als
eine Einheit gespiegelt. `RigSpace.scale = 0.701686` bleibt positiv und unverändert;
es gibt keine Einzelbein-, Kopf- oder Animationsspiegelung.

Das alte `HorseMaster.flip_h` wird **vorübergehend ebenfalls weiter gesetzt**, weil
der Master in diesem Parallelstadium noch die sichtbare Vergleichsreferenz ist.
Das ist kein Doppel-Flip des Cutout-Rigs: Master und `HorseVisual` sind Geschwister.
Beim eigentlichen Austausch in 11F entfällt die Master-Zeile vollständig.

Sonst keine Änderung an Bewegung, Perspektive, Bodenanker, Hindernisgrenzen oder
Animationen. Vor 11F müssen die automatischen Godot-/Android-Prüfungen dieses
Script-Updates grün sein.


### 11E technische Prüfung

Whole-rig-Flip-Commit: `e1398dfcd9b9e8d33faa2b1fb60ea4e001c6f777`.

- Godot-4.3-Validierung: Run `36353591506` — **success**
- Android-Debug-Build: Run `36353591523` — **success**
- `HorseVisual` ist ein äußerer Parent von `RigSpace/HorseCutoutRig`; dadurch bleibt
  die Spiegelung außerhalb aller drei AnimationPlayer und ihrer Track-Pfade.
- RIGHT behält positive X-Skalierung; LEFT invertiert nur X auf dem Gesamtcontainer.
- Eine visuelle LEFT/RIGHT-Prüfung mit laufenden Animationen folgt nach dem sichtbaren
  Austausch in 11F/11J; bis dahin bleibt der Master absichtlich sichtbar.

Kein Fehler und kein Korrekturcommit nötig. 11E ist technisch bereit für den isolierten
Austausch des sichtbaren Masters.


## 11F — Sichtbaren Master durch Cutout-Rig ersetzt

Das alte Runtime-`Sprite2D` `Main/HorseRoot/HorseMaster` wurde erst jetzt entfernt.
`HorseVisual` ist sichtbar und enthält als alleinige Pferdegrafik:

`HorseRoot → HorseVisual → RigSpace → HorseCutoutRig`.

Die bisherige Perspektivberechnung bleibt mathematisch identisch. Der einzige
Sprite-spezifische Nenner wurde eingefroren auf den bereits bestätigten alten
Runtime-Kalibrierwert:

`HORSE_VISIBLE_SOURCE_HEIGHT_PX = 768 × 1039 / 1086 = 734.762430939…`.

Dadurch muss die 1/Z-Formel nicht auf die internen Cutout-Pixelmaße umgeschrieben
werden. `RigSpace.scale = 0.701686` bildet das neue Rig auf genau diesen alten
Kalibrierraum ab. Entfernt wurden ausschließlich die nicht mehr nötigen Master-
Spezifika: Textur-Laden, Sprite-Fußanker-Konfiguration, `flip_h` und die dynamische
Texture-Height-Abfrage. Der neue Bodenanker bleibt der in 11C gemessene lokale
Rig-Offset `(0, -516.7995)`.

Unverändert bleiben `HorseRoot.position`, `HorseRoot.scale`, `HorseRoot.z_index`,
Drag/Touch, Hindernisgrenzen, Tiefenvariablen und sämtliche Rig-Animationen.

Vor diesem Commit stoppte ein lokaler Connector-Vorprüfguard den ersten Schreibversuch,
weil der zu breite Suchbegriff `HORSE_MASTER` auch den neuen Namen
`HORSE_MASTER_RUNTIME_HEIGHT_PX` traf. **Es wurde dabei nichts auf GitHub geschrieben**
und kein Runtime-Zustand verändert; der Guard wurde präzisiert und derselbe isolierte
Patch danach erneut aufgebaut.

Nächster Prüfpunkt vor weiteren Änderungen: Godot + Android für genau diesen Austausch.


### 11F technische Prüfung

Austausch-Commit: `bfba37dbc058de129e2f2605a015241ae6bca2e7`.

- Godot-4.3-Validierung: Run `36353732804` — **success**
- Android-Debug-Build: Run `36353732782` — **success**
- temporärer 11D-Scale-Preview-Workflow lief auf derselben Scene erneut: Run
  `36353732793` — **success**; die Scale-/Anchor-Ausgabe blieb unverändert

Damit lädt die Farm nach vollständiger Entfernung von `HorseMaster` technisch sauber
und lässt sich als Android-Debug-Build exportieren. Noch keine Movement-, Grenz- oder
World-Z-Logik wurde in 11F verändert.


## 11G/11H — Runtime-Prüfprobe für Input, Grenzen und World-Z

Da der Austausch den äußeren `HorseRoot` absichtlich beibehalten hat, wird die
bestehende Movement-Logik nicht vorsorglich umgeschrieben. Stattdessen prüft ein
temporärer Godot-4.3-Runtime-Runner jetzt direkt:

- Scene-Instanz ohne `HorseMaster`
- Cutout-Hierarchie, Basis-Scale und Bodenanker
- offene hintere Hofgrenze
- linke Heuballen-/Außengrenze
- rechte Unterstand-/Außengrenze
- X-/Y-Clamping
- `HorseRoot.z_index = round(depth_t × 100)`
- echte `InputEventScreenTouch`-Weiterleitung
- echte `InputEventScreenDrag`-Weiterleitung
- LEFT/RIGHT-Flip des Gesamtcontainers

Der Runner verändert keine Runtime-Datei; er schreibt ausschließlich einen
Validierungsnachweis unter `debug/`. Erst das grüne Ergebnis entscheidet, ob 11G/11H
ohne Runtime-Fix abgeschlossen werden können.


### Ergebnis 11G/11H

Movement-Probe-Commit: `2e370c20accf148d95869a09bfd975e052eca1ae`.
Workflow-Run: `36353885527` — **success**.
Ergebnis-Commit: `d0c047c3198d9ca3a8435f13971ecce92a8bbfe7`.

Runtime bestätigt ohne irgendeinen Movement-Fix:

- Touch retargetet `HorseRoot` weiterhin korrekt
- ScreenDrag retargetet weiterhin und steuert LEFT/RIGHT am Gesamt-`HorseVisual`
- offener hinterer Hof erreicht weiterhin praktisch `depth_t=0`
- linke Hindernisgrenze projiziert auf `depth_t≈0.159581`
- rechte Hindernisgrenze projiziert auf `depth_t≈0.179000`
- X-/Y-Clamping bleibt aktiv
- Perspektivscale auf `HorseRoot` bleibt positiv und uniform
- World-Z bleibt `round(depth_t × 100)` (Testwert: depth `0.369047585` → z `37`)
- Cutout-Hierarchie, `RigSpace=0.701686` und Bodenanker `-516.7995` bleiben erhalten
- `HorseMaster` ist tatsächlich nicht mehr vorhanden

Damit benötigen 11G und 11H **keine Runtime-Änderung**. Die bestehende Farm-Bewegungs-,
Grenz- und World-Z-Logik wurde erfolgreich unverändert übernommen.


## 11I/11J — echter Farm-Runtime-Preview

Für die visuelle Integrationsprüfung wurde ein temporärer Godot-Runner ergänzt, der
**die echte `main.tscn`** unter virtuellem Display rendert. Er erzeugt keine
Ersatzgrafik und rekonstruiert die Pferdeposition nicht in Python.

Vorgesehene sechs Pflichtfälle bei `1536×1384` und offenem Hof-X `0.60`:

1. FAR RIGHT — Ruheframe
2. FAR LEFT — Ruheframe
3. MID RIGHT — gemeinsamer Bewegungsframe
4. MID LEFT — gemeinsamer Bewegungsframe
5. NEAR RIGHT — Ruheframe / extreme Kameranähe
6. NEAR LEFT — Ruheframe / extreme Kameranähe

Die MID-Frames suchen deterministisch `jaw_test@0.15s`, `tail_test@0.30s` und
`walk_test@0.28s`; damit sind geöffneter Jaw, Schweifausschlag und Walk-Ausschlag
im selben Bild prüfbar. Die AnimationPlayer werden nicht umgebaut; nur der temporäre
Preview-Runner pausiert sie auf den Prüfzeitpunkten. Erst nach gespeichertem Ergebnis
wird bewertet, ob überhaupt ein Runtime-Fix nötig ist.


### Ergebnis 11I/11J — visuelle Runtime-Prüfung

Preview-Runner-Commit: `c59f9a6357024766e9462b31fe18c23d24de5212`.
Workflow-Run: `36354027200` — **success**.
Ergebnis-Commit: `7fb064f69d0c3f0f9871a6ee45e1ce6f3f17e95a`.

Der echte Godot-Render bestätigt alle sechs Pflichtfälle:

- FAR RIGHT: Cutout steht auf der hinteren Bodenlinie; Größe und Hufanker plausibel
- FAR LEFT: vollständige Figur sauber als Gesamt-Rig gespiegelt
- MID RIGHT: Walk-Ausschlag sichtbar, Jaw geöffnet, Tail ausgeschlagen; kein externer
  Perspektiv- oder Anchor-Sprung
- MID LEFT: derselbe Animationszustand bleibt nach Gesamt-Flip intakt; keine
  Doppelspiegelung einzelner Teile
- NEAR RIGHT: extreme Kameranähe funktioniert wie im alten Farm-Canon; Hufpunkt liegt
  weit unter dem Viewport, Oberkörper/Kopf werden massiv angeschnitten dargestellt
- NEAR LEFT: gleiche Nahprojektion gespiegelt, ohne Scale- oder Anchor-Wechsel

Gemessene Runtime-Werte im Preview:

- FAR: HorseRoot-Scale `0.292512327`, z `0`
- MID: HorseRoot-Scale `0.523902655`, z `50`
- NEAR: HorseRoot-Scale `2.507248402`, z `100`
- RIGHT: `HorseVisual.scale.x = +1`
- LEFT: `HorseVisual.scale.x = -1`

Die sichtbare primitive Segmentstellung im MID-Walk ist der ausdrücklich gewünschte
billige Cutout-/Puppenstil. Es ist kein Integrationsfehler erkennbar, der eine
Änderung an Walk, Pivots, Perspektive, Bodenanker oder Flip rechtfertigt.

Damit sind 11I und 11J ohne Runtime-Korrektur abgeschlossen. Als nächstes folgt nur
noch die finale technische 11K-Validierung inklusive unveränderter Animationsdaten
und Android-Debug-SHA.
