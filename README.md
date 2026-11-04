# rickpedia

Eine Flutter-App zum Erkunden von Rick-and-Morty-Charakteren mit Suche, Filtern,
seitenweisem Nachladen und Details zu Charakteren, Orten und Episoden.

Die Daten kommen von der öffentlichen [Rick and Morty API](https://rickandmortyapi.com/).
Für Daten und Bilder ist eine Internetverbindung erforderlich.

## Voraussetzungen und Start

- Flutter mit Dart passend zur SDK-Vorgabe in `pubspec.yaml` (`^3.13.5`).
- Eine für die Zielplattform eingerichtete Flutter-Umgebung; mit `flutter doctor` prüfen.

```sh
flutter pub get
flutter run -d chrome
```

Andere Zielgeräte mit `flutter devices` anzeigen und mit
`flutter run -d <device-id>` auswählen.

## Struktur

```text
lib/
  main.dart                   App-Einstieg und Theme
  core/network/               Gemeinsamer API-Zugriff und HTTP-Fehler
  features/encyclopedia/
    models/                   Charaktere, Filter, Seiten, Orte und Episoden
    services/                 Fachliche API-Aufrufe und Datenumwandlung
    controllers/              Zustand und Pagination der Charakterübersicht
    screens/                  Übersicht und Charakterdetails
    widgets/                  Karten, Filter, Listen und Detaildialoge
test/
  core/network/               Tests des gemeinsamen API-Zugriffs
  features/encyclopedia/      Service-, Controller- und Widget-Tests
assets/images/                Bildressourcen
web/                          Quelldateien für die Web-Plattform
docs/                         Eingecheckte, generierte Web-Ausgabe
```

Der gemeinsame API-Helfer übernimmt HTTPS-Anfragen, den Timeout von 15 Sekunden,
HTTP-Statusprüfung und JSON-Decodierung. Services wandeln die Daten in Models um.
Nur die Charaktersuche behandelt HTTP 404 als leeres Ergebnis; bei Detailanfragen
bleibt dieser Status ein Fehler.

## Prüfung

```sh
flutter analyze
flutter test
```

Die HTTP-Aufrufe werden in Tests mit `MockClient` und `http.runWithClient` ersetzt.

## Web-Ausgabe

`docs/` enthält generierte Deployment-Dateien und wird nicht von Hand bearbeitet.
Die vorhandene Ausgabe verwendet den Basispfad `/Rickpedia/`. Ein entsprechender
Build lässt sich mit folgendem Befehl erzeugen:

```sh
flutter build web --base-href /Rickpedia/
```

Das Ergebnis liegt unter `build/web/`. Die Übernahme nach `docs/` und das Hosting
sind derzeit nicht durch einen im Repository hinterlegten Workflow automatisiert.
