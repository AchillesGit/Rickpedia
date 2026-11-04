import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/core/network/rick_and_morty_api.dart';

void main() {
  test(
    'builds HTTPS resource URLs, encodes queries and decodes JSON',
    () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'rickandmortyapi.com');
        expect(request.url.path, '/api/character');
        expect(request.url.queryParameters, {
          'name': 'Rick & Morty',
          'page': '2',
        });
        return http.Response(
          jsonEncode({
            'results': [],
            'info': {'next': null},
          }),
          200,
        );
      });
      addTearDown(client.close);

      final data = await http.runWithClient(
        () => fetchApiJson(
          'character',
          queryParameters: {'name': 'Rick & Morty', 'page': '2'},
        ),
        () => client,
      );
      expect(data, {
        'results': [],
        'info': {'next': null},
      });
    },
  );

  test('decodes batch arrays without query parameters', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/episode/1,2');
      expect(request.url.hasQuery, isFalse);
      return http.Response('[{"id":1},{"id":2}]', 200);
    });
    addTearDown(client.close);

    expect(
      await http.runWithClient(() => fetchApiJson('episode/1,2'), () => client),
      [
        {'id': 1},
        {'id': 2},
      ],
    );
  });

  for (final status in [404, 503]) {
    test('preserves HTTP $status even for a non-JSON error body', () async {
      final client = MockClient(
        (_) async => http.Response('Unavailable', status),
      );
      addTearDown(client.close);

      await expectLater(
        http.runWithClient(() => fetchApiJson('location/1'), () => client),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', status),
        ),
      );
    });
  }

  test('rejects malformed JSON in successful responses', () async {
    final client = MockClient((_) async => http.Response('not JSON', 200));
    addTearDown(client.close);

    await expectLater(
      http.runWithClient(() => fetchApiJson('location/1'), () => client),
      throwsFormatException,
    );
  });

  testWidgets('requests time out after 15 seconds', (tester) async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);
    addTearDown(client.close);

    await http.runWithClient(() async {
      var completed = false;
      final check = expectLater(
        fetchApiJson('location/1').whenComplete(() => completed = true),
        throwsA(isA<TimeoutException>()),
      );
      await tester.pump(const Duration(seconds: 14));
      expect(completed, isFalse);
      await tester.pump(const Duration(seconds: 1));
      await check;
      response.complete(http.Response('{}', 200));
      await tester.pump();
    }, () => client);
  });
}
