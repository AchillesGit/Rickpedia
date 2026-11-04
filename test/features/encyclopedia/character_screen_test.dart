import 'test_network_image.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/features/encyclopedia/screens/character_screen.dart';
import 'package:rickpedia/features/encyclopedia/widgets/character_card.dart';

http.Response page(int start, int count, {bool next = false}) => http.Response(
  jsonEncode({
    'info': {
      'next': next ? 'https://rickandmortyapi.com/api/character?page=2' : null,
    },
    'results': List.generate(
      count,
      (i) => {
        'id': start + i,
        'name': 'Character ${start + i}',
        'status': 'Alive',
        'species': 'Human',
        'type': '',
        'image': 'https://example.com/image.png',
      },
    ),
  }),
  200,
);

void size(WidgetTester tester, double width, {double height = 900}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> mount(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CharacterScreen()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => cacheNetworkImage('https://example.com/image.png'));
  testWidgets(
    'desktop filters stay visible and apply immediately; search is debounced',
    (tester) async {
      size(tester, 1440);
      final queries = <Map<String, String>>[];
      final client = MockClient((request) async {
        queries.add(request.url.queryParameters);
        return page(1, 40);
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await mount(tester);
        expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
        final searchY = tester.getTopLeft(find.byType(TextField)).dy;
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.getTopLeft(find.byType(TextField)).dy, searchY);
        expect(find.text('Weiter'), findsNothing);
        await tester.tap(find.byType(DropdownButtonFormField<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lebendig').last);
        await tester.pumpAndSettle();
        expect(queries.last['status'], 'alive');
        expect(queries.last['page'], '1');
        final before = queries.length;
        await tester.enterText(find.byType(TextField), 'Rick');
        await tester.pump(const Duration(milliseconds: 349));
        expect(queries.length, before);
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pumpAndSettle();
        expect(queries.last['name'], 'Rick');
        expect(queries.last['status'], 'alive');
        await tester.tap(find.text('Zurücksetzen'));
        await tester.pumpAndSettle();
        expect(queries.last, {'page': '1'});
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '',
        );
        expect(tester.takeException(), isNull);
      }, () => client);
    },
  );

  testWidgets(
    'scroll appends once, retains cards on failure and retries the same page',
    (tester) async {
      size(tester, 800);
      final requests = <int>[];
      final pending = Completer<http.Response>();
      var failedOnce = false;
      final client = MockClient((request) async {
        final number = int.parse(request.url.queryParameters['page']!);
        requests.add(number);
        if (number == 1) return page(1, 20, next: true);
        if (number == 2) return pending.future;
        if (!failedOnce) {
          failedOnce = true;
          return http.Response('error', 503);
        }
        return page(41, 20);
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await mount(tester);
        final scroll = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await tester.pump();
        scroll.jumpTo(scroll.position.maxScrollExtent - 1);
        await tester.pump();
        expect(requests, [1, 2]);
        pending.complete(page(21, 20, next: true));
        await tester.pumpAndSettle();
        scroll.jumpTo(1550);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey(20)), findsOneWidget);
        expect(find.byKey(const ValueKey(21)), findsOneWidget);
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(requests, [1, 2, 3]);
        expect(
          find.text('Weitere Charaktere konnten nicht geladen werden.'),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 1));
        expect(requests, [1, 2, 3]);
        await tester.ensureVisible(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Erneut versuchen'));
        await tester.pumpAndSettle();
        expect(requests, [1, 2, 3, 3]);
        scroll.jumpTo(scroll.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(requests.length, 4);
      }, () => client);
    },
  );

  testWidgets('shows one progress indicator while keeping loaded cards', (
    tester,
  ) async {
    size(tester, 800);
    final first = Completer<http.Response>();
    final second = Completer<http.Response>();
    final client = MockClient(
      (request) => request.url.queryParameters['page'] == '1'
          ? first.future
          : second.future,
    );
    addTearDown(client.close);
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: CharacterScreen()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CharacterCard), findsNothing);
      first.complete(page(1, 20, next: true));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final scroll = tester
          .widget<CustomScrollView>(find.byType(CustomScrollView))
          .controller!;
      scroll.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CharacterCard), findsWidgets);
      final offset = scroll.offset;
      second.complete(page(21, 20));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(scroll.offset, offset);
      expect(scroll.position.maxScrollExtent, greaterThan(offset));
    }, () => client);
  });
  testWidgets('fills an empty viewport and ignores obsolete filter responses', (
    tester,
  ) async {
    size(tester, 1440);
    final oldResponse = Completer<http.Response>();
    final queries = <Map<String, String>>[];
    final client = MockClient((request) async {
      final query = request.url.queryParameters;
      queries.add(query);
      if (query['name'] == null && query['page'] == '2') {
        return oldResponse.future;
      }
      if (query['name'] != null) return page(100, 1);
      return page(1, 1, next: true);
    });
    addTearDown(client.close);
    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: CharacterScreen()));
      for (var i = 0; i < 6; i++) {
        await tester.pump();
      }
      expect(queries.length, 2);
      await tester.enterText(find.byType(TextField), 'Morty');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('Character 100'), findsOneWidget);
      oldResponse.complete(page(2, 1, next: true));
      await tester.pumpAndSettle();
      expect(find.text('Character 2'), findsNothing);
      expect(queries.length, 3);
    }, () => client);
  });

  testWidgets('initial errors retry and no results can reset filters', (
    tester,
  ) async {
    size(tester, 1440);
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return requests == 1 ? http.Response('error', 503) : page(1, 0);
    });
    addTearDown(client.close);
    await http.runWithClient(() async {
      await mount(tester);
      expect(
        find.text('Charaktere konnten nicht geladen werden.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Erneut versuchen'));
      await tester.pumpAndSettle();
      expect(find.text('Keine Charaktere gefunden.'), findsOneWidget);
      expect(requests, 2);
      await tester.enterText(find.byType(TextField), 'Nobody');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Filter zurücksetzen'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(requests, 4);
    }, () => client);
  });

  testWidgets('resizing loads more and switches compact filters to desktop', (
    tester,
  ) async {
    size(tester, 800, height: 500);
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return page(requests == 1 ? 1 : 21, 20, next: requests == 1);
    });
    addTearDown(client.close);
    await http.runWithClient(() async {
      await mount(tester);
      expect(requests, 1);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      tester.view.physicalSize = const Size(1440, 1600);
      await tester.pumpAndSettle();
      expect(requests, 2);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(3));
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Charaktere filtern'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, () => client);
  });

  for (final delayed in [false, true]) {
    testWidgets('filter resets scroll position (delayed response: $delayed)', (
      tester,
    ) async {
      size(tester, 800);
      final pending = Completer<http.Response>();
      final client = MockClient((request) async {
        if (request.url.queryParameters['name'] != null && delayed) {
          return pending.future;
        }
        return page(1, 40);
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await mount(tester);
        final scroll = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        scroll.jumpTo(600);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Rick');
        await tester.pump(const Duration(milliseconds: 350));
        if (delayed) {
          await tester.pump();
          expect(find.byType(CustomScrollView), findsNothing);
          pending.complete(page(100, 40));
        }
        await tester.pumpAndSettle();
        final updatedScroll = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        expect(updatedScroll.offset, 0);
        expect(tester.takeException(), isNull);
      }, () => client);
    });
  }

  testWidgets(
    'returning from details preserves results, filters and scroll offset',
    (tester) async {
      size(tester, 1440);
      var requests = 0;
      final client = MockClient((_) async {
        requests++;
        return page(1, 40);
      });
      addTearDown(client.close);
      await http.runWithClient(() async {
        await mount(tester);
        await tester.enterText(find.byType(TextField), 'Rick');
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        final scroll = tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!;
        scroll.jumpTo(600);
        await tester.pumpAndSettle();
        final before = requests;
        final card = find.byType(CharacterCard).hitTestable().first;
        await tester.tap(card);
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(scroll.offset, 600);
        expect(requests, before);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Rick',
        );
        expect(tester.takeException(), isNull);
      }, () => client);
    },
  );
}
