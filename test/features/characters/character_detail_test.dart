import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rickpedia/features/characters/models/character.dart';
import 'package:rickpedia/features/characters/screens/character_detail_screen.dart';
import 'package:rickpedia/features/characters/screens/character_screen.dart';
import 'package:rickpedia/features/characters/widgets/character_card.dart';
import 'package:rickpedia/features/characters/widgets/character_image.dart';

void main() {
  final json = <String, dynamic>{
    'id': 1,
    'name': 'Rick Sanchez',
    'status': 'Alive',
    'species': 'Human',
    'type': '',
    'image': 'https://example.com/rick.png',
    'gender': 'Male',
    'origin': {'name': 'Earth (C-137)'},
    'location': {'name': 'Citadel of Ricks'},
    'episode': ['episode/1', 'episode/2'],
  };

  test('parses additional character information', () {
    final character = Character.fromJson(json);
    expect(character.gender, 'Male');
    expect(character.origin, 'Earth (C-137)');
    expect(character.location, 'Citadel of Ricks');
    expect(character.episodeCount, 2);
  });

  testWidgets('opens details from a card and returns to the list', (
    tester,
  ) async {
    var requests = 0;
    final client = MockClient((_) async {
      requests++;
      return http.Response(
        jsonEncode({
          'info': {'next': null},
          'results': [json],
        }),
        200,
      );
    });
    addTearDown(client.close);

    await http.runWithClient(() async {
      await tester.pumpWidget(const MaterialApp(home: CharacterScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CharacterCard));
      await tester.pumpAndSettle();

      expect(find.byType(CharacterDetailScreen), findsOneWidget);
      expect(find.text('Earth (C-137)'), findsOneWidget);
      expect(find.text('Citadel of Ricks'), findsOneWidget);
      expect(find.text('Typ'), findsNothing);
      expect(
        tester.widget<CharacterImage>(find.byType(CharacterImage)).size,
        greaterThan(100),
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(CharacterCard), findsOneWidget);
      expect(requests, 1);
    }, () => client);
  });

  testWidgets('details fit narrow screens and handle missing images', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: CharacterDetailScreen(character: Character.fromJson(json)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Episodenauftritte'), 150);
    expect(find.text('Episodenauftritte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
