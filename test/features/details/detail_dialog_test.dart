import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/features/characters/models/character.dart';
import 'package:rickpedia/features/characters/screens/character_detail_screen.dart';
import 'package:rickpedia/features/details/widgets/detail_dialog.dart';
import 'package:rickpedia/features/details/widgets/episode_detail_dialog.dart';
import 'package:rickpedia/features/details/widgets/location_detail_dialog.dart';

import '../characters/test_network_image.dart';

const _base = 'https://rickandmortyapi.com/api';
const _image = 'https://example.com/rick.png';
final _character = Character.fromJson(_characterJson(1));

Map<String, dynamic> _characterJson(int id) => {
  'id': id,
  'name': 'Character $id',
  'status': 'Alive',
  'species': 'Human',
  'type': '',
  'image': _image,
  'origin': {'name': 'Earth', 'url': '$_base/location/1'},
  'location': {'name': 'Citadel', 'url': '$_base/location/3'},
  'episode': ['$_base/episode/1', '$_base/episode/2'],
};

Map<String, dynamic> _episode(int id) => {
  'id': id,
  'name': 'Episode $id',
  'episode': 'S01E$id',
  'air_date': 'December 2, 2013',
  'characters': ['$_base/character/2'],
};

http.Response _json(Object data) => http.Response(jsonEncode(data), 200);

Future<void> _open(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(find.text(label), 200);
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => cacheNetworkImage(_image));

  for (final label in ['Herkunft', 'Letzter bekannter Aufenthaltsort']) {
    testWidgets('$label opens location and returns from a resident', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final requests = <String>[];
      final client = MockClient((request) async {
        requests.add(request.url.path);
        if (request.url.path.startsWith('/api/location/')) {
          return _json({
            'id': 1,
            'name': 'Location name',
            'type': 'Planet',
            'dimension': 'unknown',
            'residents': ['$_base/character/2'],
          });
        }
        return _json(_characterJson(2));
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: CharacterDetailScreen(character: _character)),
        );
        await tester.pumpAndSettle();
        expect(requests, isEmpty);
        await _open(tester, label);
        expect(
          requests.first,
          label == 'Herkunft' ? '/api/location/1' : '/api/location/3',
        );
        expect(find.text('Planet'), findsOneWidget);
        expect(find.text('Unbekannt').hitTestable(), findsOneWidget);
        expect(find.text('Alive · Human'), findsOneWidget);
        await tester.tap(find.text('Character 2'));
        await tester.pumpAndSettle();
        expect(find.byType(CharacterDetailScreen), findsOneWidget);
        expect(find.text('Character 2'), findsNWidgets(2));
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(LocationDetailDialog), findsOneWidget);
        expect(requests, hasLength(2));
        await tester.tap(find.byTooltip('Schließen'));
        await tester.pumpAndSettle();
        expect(find.byType(DetailDialog), findsNothing);
      }, () => client);
    });
  }

  testWidgets(
    'episodes open details, characters, and return to the same list',
    (tester) async {
      final requests = <String>[];
      final client = MockClient((request) async {
        requests.add(request.url.path);
        return request.url.path.contains('/episode/')
            ? _json([_episode(1), _episode(2)])
            : _json(_characterJson(2));
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: CharacterDetailScreen(character: _character)),
        );
        await tester.pumpAndSettle();
        await _open(tester, 'Episodenauftritte');
        expect(find.text('S01E1'), findsOneWidget);
        await tester.tap(find.text('Episode 1'));
        await tester.pumpAndSettle();
        expect(find.text('December 2, 2013'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Character 2'),
          150,
          scrollable: find
              .descendant(
                of: find.byType(DetailDialog),
                matching: find.byType(Scrollable),
              )
              .last,
        );
        await tester.tap(find.text('Character 2'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byTooltip('Zur Episodenliste'), findsOneWidget);
        await tester.tap(find.byTooltip('Zur Episodenliste'));
        await tester.pumpAndSettle();
        expect(find.text('Episode 2'), findsOneWidget);
        expect(requests, ['/api/episode/1,2', '/api/character/2']);
      }, () => client);
    },
  );

  testWidgets('pagination retries only the failed batch and preserves scroll', (
    tester,
  ) async {
    var secondBatchCalls = 0;
    final requests = <String>[];
    final client = MockClient((request) async {
      requests.add(request.url.path);
      if (request.url.path.contains('/character/')) {
        return _json(_characterJson(2));
      }
      final ids = request.url.pathSegments.last
          .split(',')
          .map(int.parse)
          .toList();
      if (ids.first == 21 && ++secondBatchCalls == 1) {
        return http.Response('{}', 503);
      }
      return _json(ids.map(_episode).toList());
    });
    addTearDown(client.close);
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: EpisodeDetailDialog(
            urls: List.generate(21, (i) => '$_base/episode/${i + 1}'),
            onCharacterSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Mehr laden'), 300);
      await tester.tap(find.text('Mehr laden'));
      await tester.pumpAndSettle();
      expect(find.text('Episode 20'), findsOneWidget);
      await tester.ensureVisible(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Episode 21'), 100);
      final scrollable = find.byType(Scrollable).first;
      final offset = tester.state<ScrollableState>(scrollable).position.pixels;
      await tester.tap(find.text('Episode 21'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Zur Episodenliste'));
      await tester.pumpAndSettle();
      expect(tester.state<ScrollableState>(scrollable).position.pixels, offset);
      expect(requests.where((path) => path == '/api/episode/21'), hasLength(2));
      expect(
        requests,
        hasLength(4),
      ); // Initial batch, failed batch, retry, character list.
    }, () => client);
  });

  testWidgets('location retry, empty residents, and narrow dialog fit', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var calls = 0;
    final client = MockClient((_) async {
      if (++calls == 1) return http.Response('{}', 404);
      return _json({
        'id': 1,
        'name': 'A very long location name to wrap on mobile',
        'type': 'Planet',
        'dimension': 'unknown',
        'residents': [],
      });
    });
    addTearDown(client.close);
    await http.runWithClient(() async {
      await tester.pumpWidget(
        MaterialApp(home: CharacterDetailScreen(character: _character)),
      );
      await tester.pumpAndSettle();
      await _open(tester, 'Herkunft');
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Keine Bewohner bekannt.'),
        150,
        scrollable: find.descendant(
          of: find.byType(DetailDialog),
          matching: find.byType(Scrollable),
        ),
      );
      expect(calls, 2);
      expect(tester.takeException(), isNull);
    }, () => client);
  });

  for (final label in ['Herkunft', 'Episodenauftritte']) {
    testWidgets('closing $label during a request is safe', (tester) async {
      final response = Completer<http.Response>();
      final client = MockClient((_) => response.future);
      addTearDown(client.close);
      await http.runWithClient(() async {
        await tester.pumpWidget(
          MaterialApp(home: CharacterDetailScreen(character: _character)),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text(label), 200);
        await tester.tap(find.text(label));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(find.byTooltip('Schließen'));
        await tester.pumpAndSettle();
        response.complete(http.Response('{}', 503));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }, () => client);
    });
  }

  testWidgets('missing location links are unknown and not clickable', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CharacterDetailScreen(
          character: Character(
            id: 1,
            name: 'Rick',
            status: 'Alive',
            species: 'Human',
            type: '',
            imageUrl: _image,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final label in ['Herkunft', 'Letzter bekannter Aufenthaltsort']) {
      final tile = tester.widget<ListTile>(
        find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
      );
      expect(tile.onTap, isNull);
      expect((tile.subtitle! as Text).data, 'Unbekannt');
    }
  });
}
