import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/features/characters/models/character_filter.dart';
import 'package:rickpedia/features/characters/services/character_service.dart';

void main() {
  test(
    'combines all filters with pagination and safely encodes text',
    () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters, {
          'page': '2',
          'name': 'Rick & Morty',
          'status': 'alive',
          'species': 'Human',
          'gender': 'male',
        });
        return http.Response(
          jsonEncode({
            'info': {
              'next': 'https://rickandmortyapi.com/api/character?page=3',
            },
            'results': [
              {
                'id': 1,
                'name': 'Rick',
                'status': 'Alive',
                'species': 'Human',
                'type': 'Rick clone',
                'image': 'https://example.com/rick.png',
              },
            ],
          }),
          200,
        );
      });
      addTearDown(client.close);
      final page = await http.runWithClient(
        () => fetchCharacters(
          page: 2,
          filter: const CharacterFilter(
            name: ' Rick & Morty ',
            status: 'alive',
            species: 'Human',
            gender: 'male',
          ),
        ),
        () => client,
      );
      expect(page.characters.single.name, 'Rick');
      expect(page.characters.single.type, 'Rick clone');
      expect(page.hasNextPage, isTrue);
    },
  );

  test('omits blank filters', () {
    expect(const CharacterFilter(name: '  ').toQueryParameters(), isEmpty);
    expect(const CharacterFilter().isActive, isFalse);
    expect(const CharacterFilter(status: 'unknown').isActive, isTrue);
  });

  test('404 produces an empty page without further pages', () async {
    final client = MockClient(
      (_) async => http.Response('{"error":"There is nothing here"}', 404),
    );
    addTearDown(client.close);
    final page = await http.runWithClient(
      () => fetchCharacters(),
      () => client,
    );
    expect(page.characters, isEmpty);
    expect(page.hasNextPage, isFalse);
  });

  test('server failures remain errors', () async {
    final client = MockClient((_) async => http.Response('Unavailable', 503));
    addTearDown(client.close);
    await expectLater(
      http.runWithClient(() => fetchCharacters(), () => client),
      throwsException,
    );
  });
}
