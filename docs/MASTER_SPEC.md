# MASTER SPEC — Pferd und Steve

Stand: 2026-09-27

## Kernidee

Bewusst simpel produzierter Mobile-Pferdesimulator/Tamagotchi. Der Spieler ist Farmer Steve und kümmert sich zunächst relativ normal um ein Pferd. Mit der Zeit wird die Welt immer merkwürdiger. Normalität und Langeweile bleiben wichtig, damit absurde Ereignisse stärker wirken.

## Humor

- trocken
- improvisiert wirkend
- absurde Non-Sequiturs
- unerwartete Richtungswechsel
- Anti-Punchlines
- unnötig konkrete Details
- gelegentliche Versprecher/Selbstkorrekturen
- Running Gags dürfen sehr spät zurückkehren
- keine kopierten Dialoge oder Figuren bestehender Werke

Vertonung zunächst vollständig auf Deutsch. Das Pferd wird vom Nutzer selbst gesprochen.

## Visueller Stil

### Farm
- gesättigter 2D-Comiclook
- flach, simpel, bunt
- bewusst grobe Cutout-/Cartoon-DNA

### Interaktive/bewegliche Objekte
- möglichst realistisch/fotorealistisch
- Pferd, Farmer Steve, Eimer, Futter, Werkzeuge etc.
- der Stilbruch Comic-Farm + reales PNG ist absichtlich Teil des Humors

## Farm-Canon

Zwei Hintergründe derselben Szene:
- Tag
- Nacht

Komposition:
- links große rote offene Scheune
- Mitte großer freier Hof/Paddock
- weißer Zaun und Landschaft im Hintergrund
- rechts offener Unterstand
- vorne viel freie Fläche
- hinten kleiner wirkende Spielfläche für Pseudo-3D

## Pseudo-3D

Reines 2D.

- weiter unten/vorne = größer
- weiter oben/hinten = kleiner
- grobe Zielwerte: vorne 115–130 %, Mitte 100 %, hinten 70–85 %
- später Y-basierte Z-Sortierung
- Schatten kann mitskalieren

## Pferd — verbindliche Regeln

- realistisches/fotorealistisches chestnut/braunes Pferd
- dunkle Mähne
- dunkler Schweif
- natürliche weiße Blesse
- genau eine Seitenperspektive
- RIGHT = Original
- LEFT = horizontal gespiegelt
- keine Front-, Rück- oder 3/4-Ansichten
- STEHEND ist die Master-Pose

### Rig

Grundteile:
- Körper
- fester oberer Kopf
- separater Unterkiefer
- separater Schweif
- 4 Beine mit je 3 Segmenten = 12 Beinsegmente

### Mund

Der Kopf wird NICHT quer durch Nase oder Schnauze geteilt.

Nur der Unterkiefer wird wie mit einer Bastelschere entlang der natürlichen Mundöffnung abgetrennt.

- Drehpunkt ungefähr am hinteren Mundwinkel
- Unterkiefer klappt nur hoch/runter
- absichtlich billige Puppenbewegung
- kein komplexes Lip-Sync
- leichte Unregelmäßigkeit beim Sprechen erwünscht

### Beine

- bewusst billige Cutout-Puppenanimation
- Segmentrotation statt realistischer Gangsimulation
- Pferd darf leicht gleiten/wackeln
- Anatomie bleibt vollständig; keine fehlenden Gliedmaßen
- keine AAA-Animation

### Kopfbewegung

Der komplette ausgeschnittene Kopf darf leicht hoch/runter rotieren.
Es ist nicht wichtig, dass die Bewegung elegant aussieht; der primitive Sticker-/Bastelcharakter ist gewünscht.

## Fertige Assets

- farm_day_v01.png
- farm_night_v01.png
- horse_master_standing_v01.png
- horse_head_upper_v01.png
- horse_jaw_v01.png
- horse_head_talk_halfopen_preview_v01.png
- horse_head_talk_open_preview_v01.png
- horse_body_v01.png
- horse_tail_v01.png
- horse_front_legs_segments_sheet_v01.png
- horse_hind_legs_segments_sheet_v01.png

## Offene Assets / später

- einzelne 12 Beinsegmente bei Bedarf aus den Segment-Sheets exportieren
- Schlafpose
- eventuell Fresspose
- eventuell Trinkpose
- Farmer Steve
- interaktive Gegenstände

## Verworfene Varianten

- kompletter Schnitt quer durch die Schnauze
- bewegter halber Kopf
- zusätzliche Kopf-Perspektiven
- anatomisch komplexe Mundanimation
- große überladene Asset-Sheets als Hauptworkflow
- realistischer/aufwendiger Pferdegang

## Aktuell nächste technische Aufgabe

Assets sauber ins Repository legen und anschließend eine minimale Mobile-App-Szene bauen, in der:
1. Farm-Hintergrund angezeigt wird,
2. Master-Pferd auf dem Hof steht,
3. das Pferd horizontal gespiegelt werden kann,
4. Y-Position die Größe steuert,
5. Kopf/Unterkiefer/Schweif/Beinsegmente als primitives Cutout-Rig testbar werden.
