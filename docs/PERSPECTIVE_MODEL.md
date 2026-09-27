# Perspektivmodell für das Pferd

Stand: 2026-09-27

## Ziel

Das Pferd soll sich auf der gezeichneten Farm so verhalten, als würde es auf einer flachen Bodenebene auf die Kamera zu- oder von ihr weglaufen.

Wichtige visuelle Regeln:

- Der obere Rand des begehbaren Bereichs liegt auf dem Hofboden, nicht auf Zaun oder Wiese dahinter.
- Hinten bleibt das Pferd bereits klar lesbar und etwas größer als im ersten Testbuild.
- Nach vorne wächst es stark, aber nicht durch willkürliches lineares Hochskalieren.
- Direkt an der Kamera darf der projizierte Hufpunkt unterhalb des sichtbaren Bildschirms liegen. Dadurch werden Beine und Unterkörper natürlich abgeschnitten und sichtbar bleiben überwiegend Kopf, Hals und oberer Körper.

## Referenzen

Mathematische Grundlage:

- OpenCV, Pinhole Camera Model:
  https://docs.opencv.org/5.0/main_modules/d_projection.html

Die zentrale Beziehung ist die normale perspektivische Projektion:

`u = fx * X / Z + cx`
`v = fy * Y / Z + cy`

Damit sind scheinbare Größe und Abstand eines Bodenpunktes vom Horizont proportional zu `1 / Z`.

Pferde-Proportionen:

- University of Minnesota Extension, gemessene erwachsene Pferde:
  https://extension.umn.edu/agriculture/animals-and-livestock/horse/estimating-horse-bodyweight
- In den dortigen Messdaten liegen typische ausgewachsene Reitpferde ungefähr bei 60–66 Zoll Widerristhöhe; für unser Projekt wird deshalb eine plausible Referenzhöhe von 1,65 m verwendet.
- UMN beschreibt ein proportioniertes Pferd außerdem näherungsweise als quadratisch: Höhe vom Widerrist bis zum Boden ungefähr gleich der Körperlänge:
  https://extension.umn.edu/agriculture/animals-and-livestock/horse/conformation-of-the-horse

Fotografische Perspektiv-Referenzen:

- Nahes Pferd / starke Vordergrundwirkung:
  https://unsplash.com/photos/a-close-up-of-a-horse-standing-on-top-of-a-lush-green-field-IcqGTAAWAiE
- Sehr naher Pferde-Vordergrund:
  https://unsplash.com/photos/horse-legs-stand-close-to-the-viewer-am9LfBGnkkk
- Seitenansicht eines Pferdes am Feld/Zaun:
  https://www.pexels.com/photo/horse-standing-on-field-behind-enclosure-4582534/

Die Fotos werden nur als Größen-/Perspektivreferenz verwendet. Es werden daraus keine Assets übernommen.

## Kalibrierung auf unsere Farm

Erster Testbuild auf dem Fold:

- Screenshotgröße: 1536 × 1384 px.
- Im alten System war das weit hinten stehende Pferd nur ungefähr 109 px hoch.
- Selbst vorne waren es nur ungefähr 176 px.
- Zusätzlich lag der Sprite-Ursprung in der Bildmitte und nicht an den Hufen. Dadurch konnte das Pferd optisch auf Zaun und Hintergrund schweben.

Neue Kalibrierung:

- hinterste bedienbare Bodenlinie: `0.565 × Bildschirmhöhe`
- angenäherter Horizont: `0.405 × Bildschirmhöhe`
- angenommene Pferdehöhe: `1.65 m`
- angenommene Kamerahöhe: `1.70 m`
- hintere Distanz: `12.0 m`
- extreme Nahdistanz: `1.40 m`

Der Spieler zieht weiterhin nur innerhalb des sichtbaren Bodens. Dieser Eingabewert wird aber in eine Weltentfernung `Z` umgerechnet.

`Z = lerp(12.0 m, 1.40 m, depth_t)`

Danach wird die Perspektive über den Kehrwert der Tiefe berechnet:

`gain = 12.0 / Z`

Der projizierte Hufpunkt:

`foot_y = horizon_y + (far_foot_y - horizon_y) * gain`

Die projizierte Pferdehöhe:

`horse_height = (1.65 / 1.70) * (foot_y - horizon_y)`

Dadurch entsteht automatisch eine starke, physikalisch plausible Größensteigerung beim Annähern.

## Extrem-Nahbereich

Bei 1,40 m ergibt das Modell einen projizierten Hufpunkt deutlich unterhalb der Bildschirmkante.

Das ist beabsichtigt.

Der Sprite ist jetzt an seinem tatsächlichen Huf-/Bodenkontakt verankert. Wenn das Pferd sehr nah kommt, liegt dieser Kontaktpunkt außerhalb des sichtbaren Bildes. Dadurch werden Unterkörper und Beine vom Viewport abgeschnitten, statt das komplette Pferd einfach nur riesig in den Bildschirm zu quetschen.

Das Zielbild am unteren Rand ist daher ungefähr:

- Kopf sichtbar
- Hals sichtbar
- Schulter / oberer Rumpf sichtbar
- Beine größtenteils oder vollständig außerhalb des Bildes

## Canon-Asset-Kalibrierung

Das bestätigte Master-Pferd wurde nicht verändert.

Aus dem transparenten Canon-Asset wurden lediglich dimensionslose Ankerwerte abgeleitet:

- sichtbare Pferdehöhe: `1039 / 1086` der Texturhöhe
- Bodenkontakt/Hufe: `1055 / 1086` der Texturhöhe

Dadurch bleibt die Verankerung korrekt, auch wenn dieselbe Mastergrafik intern auf eine andere Auflösung skaliert wird.
