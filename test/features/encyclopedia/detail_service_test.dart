import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/features/encyclopedia/models/character.dart';
import 'package:rickpedia/features/encyclopedia/models/episode.dart';
import 'package:rickpedia/features/encyclopedia/models/location.dart';
import 'package:rickpedia/features/encyclopedia/services/detail_service.dart';

void main() {
  test('models retain links and tolerate absent optional fields', () {
    final character = Character.fromJson({
      'id': 1,
      'name': 'Rick',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'image': '',
      'origin': {
        'name': 'Earth',
        'url': 'https://rickandmortyapi.com/api/location/1',
      },
      'location': {
        'name': 'Citadel',
        'url': 'https://rickandmortyapi.com/api/location/3',
      },
      'episode': ['https://rickandmortyapi.com/api/episode/1'],
    });
    expect(character.originUrl, endsWith('/location/1'));
    expect(character.locationUrl, endsWith('/location/3'));
    expect(character.episodeUrls, hasLength(1));
    expect(character.episodeCount, 1);
    final minimal = Character.fromJson({
      'id': 2,
      'name': 'Morty',
      'status': 'Alive',
      'species': 'Human',
      'type': '',
      'image': '',
    });
    expect(minimal.originUrl, isEmpty);
    expect(minimal.locationUrl, isEmpty);
    expect(minimal.episodeUrls, isEmpty);
    expect(Episode.fromJson({'id': 1, 'name': 'Pilot'}).characterUrls, isEmpty);
    expect(Location.fromJson({'id': 1, 'name': 'Earth'}).residentUrls, isEmpty);
  });

  test(
    'batch requests preserve requested order and support a single object',
    () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'rickandmortyapi.com');
        if (request.url.path == '/api/episode/2,1') {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'name': 'Pilot',
                'episode': 'S01E01',
                'air_date': 'December 2, 2013',
                'characters': ['character/1'],
              },
              {'id': 2, 'name': 'Lawnmower Dog'},
            ]),
            200,
          );
        }
        expect(request.url.path, '/api/character/1');
        return http.Response(
          jsonEncode({
            'id': 1,
            'name': 'Rick',
            'status': 'Alive',
            'species': 'Human',
            'type': '',
            'image': '',
          }),
          200,
        );
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        final episodes = await fetchEpisodesByIds([2, 1]);
        expect(episodes.map((e) => e.id), [2, 1]);
        expect(episodes.last.code, 'S01E01');
        expect(episodes.last.airDate, 'December 2, 2013');
        expect(episodes.last.characterUrls, ['character/1']);
        expect((await fetchCharactersByIds([1])).single.name, 'Rick');
      }, () => client);
    },
  );

  test(
    'location parses metadata and empty batches do not request data',
    () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        expect(request.url.path, '/api/location/3');
        return http.Response(
          jsonEncode({
            'id': 3,
            'name': 'Citadel',
            'type': 'Space station',
            'dimension': 'unknown',
            'residents': ['character/1'],
          }),
          200,
        );
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        expect(await fetchEpisodesByIds([]), isEmpty);
        expect(await fetchCharactersByIds([]), isEmpty);
        final location = await fetchLocation(3);
        expect(location.type, 'Space station');
        expect(location.dimension, 'unknown');
        expect(location.residentUrls, ['character/1']);
        expect(calls, 1);
      }, () => client);
    },
  );

  for (final status in [404, 503]) {
    test('detail HTTP $status remains an error', () async {
      final client = MockClient((_) async => http.Response('{}', status));
      addTearDown(client.close);
      await http.runWithClient(() async {
        await expectLater(fetchLocation(1), throwsException);
        await expectLater(fetchEpisodesByIds([1]), throwsException);
        await expectLater(fetchCharactersByIds([1]), throwsException);
      }, () => client);
    });
  }

  testWidgets('detail requests time out after 15 seconds', (tester) async {
    final client = MockClient((_) => Completer<http.Response>().future);
    addTearDown(client.close);
    await http.runWithClient(() async {
      final check = expectLater(
        fetchLocation(1),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pump(const Duration(seconds: 15));
      await check;
    }, () => client);
  });
}
