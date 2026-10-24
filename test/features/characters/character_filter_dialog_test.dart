import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rickpedia/features/characters/models/character_filter.dart';
import 'package:rickpedia/features/characters/widgets/character_filter_dialog.dart';

void main() {
  testWidgets('edits existing filters and returns them only on apply', (
    tester,
  ) async {
    CharacterFilter? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                result = await showDialog<CharacterFilter>(
                  context: context,
                  builder: (_) => const CharacterFilterDialog(
                    filter: CharacterFilter(
                      name: 'Rick',
                      status: 'alive',
                      gender: 'male',
                    ),
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Rick'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, ' Morty ');
    await tester.tap(find.text('Anwenden'));
    await tester.pumpAndSettle();
    expect(result?.name, 'Morty');
    expect(result?.status, 'alive');
    expect(result?.gender, 'male');

    result = null;
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
