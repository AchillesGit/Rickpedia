import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rickpedia/features/characters/controllers/character_controller.dart';
import 'package:rickpedia/features/characters/models/character.dart';
import 'package:rickpedia/features/characters/models/character_filter.dart';
import 'package:rickpedia/features/characters/models/character_page.dart';

CharacterPage page(int id, {bool next = false}) => CharacterPage(
  characters: [
    Character(
      id: id,
      name: 'Character $id',
      status: 'Alive',
      species: 'Human',
      type: '',
      imageUrl: '',
    ),
  ],
  hasNextPage: next,
);

void main() {
  test(
    'appends pages, blocks duplicate loads and exposes readonly results',
    () async {
      final pending = Completer<CharacterPage>();
      final requests = <int>[];
      final controller = CharacterController(
        fetch: ({required page, required filter}) {
          requests.add(page);
          return page == 1
              ? pending.future
              : Future.value(CharacterPage(characters: [], hasNextPage: true));
        },
      );
      addTearDown(controller.dispose);

      final first = controller.loadMore();
      await controller.loadMore();
      expect(requests, [1]);
      expect(controller.loading, isTrue);
      pending.complete(page(1, next: true));
      await first;
      expect(controller.characters.map((c) => c.id), [1]);
      expect(() => controller.characters.clear(), throwsUnsupportedError);
      await controller.loadMore();
      expect(controller.characters.map((c) => c.id), [1]);
      expect(controller.hasNext, isFalse);
      await controller.loadMore();
      expect(requests, [1, 2]);
    },
  );

  test('retains results on failure and retries the same page', () async {
    final requests = <int>[];
    var fail = true;
    final controller = CharacterController(
      fetch: ({required page, required filter}) async {
        requests.add(page);
        if (page == 2 && fail) {
          fail = false;
          throw StateError('offline');
        }
        return CharacterPage(
          characters: [
            Character(
              id: page,
              name: '$page',
              status: '',
              species: '',
              type: '',
              imageUrl: '',
            ),
          ],
          hasNextPage: page == 1,
        );
      },
    );
    addTearDown(controller.dispose);
    await controller.loadMore();
    await controller.loadMore();
    expect(controller.failed, isTrue);
    expect(controller.loading, isFalse);
    expect(controller.characters.map((c) => c.id), [1]);
    await controller.loadMore();
    expect(requests, [1, 2, 2]);
    expect(controller.failed, isFalse);
    expect(controller.characters.map((c) => c.id), [1, 2]);
    expect(controller.hasNext, isFalse);
  });

  for (final obsoleteFails in [false, true]) {
    test(
      'filter change ignores obsolete ${obsoleteFails ? 'failure' : 'success'}',
      () async {
        final obsolete = Completer<CharacterPage>();
        final current = Completer<CharacterPage>();
        final requests = <(int, String)>[];
        final controller = CharacterController(
          fetch: ({required page, required filter}) {
            requests.add((page, filter.name));
            return filter.name.isEmpty ? obsolete.future : current.future;
          },
        );
        addTearDown(controller.dispose);
        final oldLoad = controller.loadMore();
        controller.applyFilter(const CharacterFilter(name: 'Rick'));
        expect(requests, [(1, ''), (1, 'Rick')]);
        expect(controller.filter.name, 'Rick');
        expect(controller.filterRevision, 1);
        if (obsoleteFails) {
          obsolete.completeError(StateError('obsolete'));
        } else {
          obsolete.complete(page(1, next: true));
        }
        await oldLoad;
        expect(controller.characters, isEmpty);
        expect(controller.loading, isTrue);
        expect(controller.failed, isFalse);
        current.complete(page(100));
        await pumpEventQueue();
        expect(controller.characters.map((c) => c.id), [100]);
        expect(controller.loading, isFalse);
      },
    );
  }

  for (final fails in [false, true]) {
    test('ignores ${fails ? 'failure' : 'success'} after disposal', () async {
      final pending = Completer<CharacterPage>();
      var notifications = 0;
      final controller = CharacterController(
        fetch: ({required page, required filter}) => pending.future,
      )..addListener(() => notifications++);
      final load = controller.loadMore();
      expect(notifications, 1);
      controller.dispose();
      if (fails) {
        pending.completeError(StateError('offline'));
      } else {
        pending.complete(page(1));
      }
      await load;
      expect(notifications, 1);
      expect(controller.characters, isEmpty);
      expect(controller.failed, isFalse);
    });
  }
}
