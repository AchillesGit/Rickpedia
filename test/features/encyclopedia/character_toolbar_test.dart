import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rickpedia/features/encyclopedia/models/character_filter.dart';
import 'package:rickpedia/features/encyclopedia/widgets/character_filter_dialog.dart';
import 'package:rickpedia/features/encyclopedia/widgets/character_toolbar.dart';

Future<void> mount(
  WidgetTester tester,
  List<CharacterFilter> changes, {
  bool desktop = false,
  CharacterFilter initial = const CharacterFilter(),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(desktop ? 1440 : 800, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  var filter = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => CharacterToolbar(
            filter: filter,
            desktop: desktop,
            onChanged: (value) {
              changes.add(value);
              setState(() => filter = value);
            },
          ),
        ),
      ),
    ),
  );
}

Finder get dialogSearch => find.descendant(
  of: find.byType(CharacterFilterDialog),
  matching: find.byType(TextField),
);

void main() {
  testWidgets('debounces the latest name and preserves the other filters', (
    tester,
  ) async {
    final changes = <CharacterFilter>[];
    await mount(
      tester,
      changes,
      initial: const CharacterFilter(status: 'alive'),
    );
    await tester.enterText(find.byType(TextField), 'Ric');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(find.byType(TextField), ' Rick ');
    await tester.pump(const Duration(milliseconds: 349));
    expect(changes, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(changes.single.name, 'Rick');
    expect(changes.single.status, 'alive');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Rick',
    );
  });

  testWidgets('applying the dialog replaces a pending search exactly once', (
    tester,
  ) async {
    final changes = <CharacterFilter>[];
    await mount(tester, changes);
    await tester.enterText(find.byType(TextField), 'Rick');
    await tester.tap(find.byTooltip('Charaktere filtern'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    expect(tester.widget<TextField>(dialogSearch).controller!.text, 'Rick');
    await tester.enterText(dialogSearch, 'Morty');
    await tester.tap(find.text('Anwenden'));
    await tester.pumpAndSettle();
    expect(changes.single.name, 'Morty');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Morty',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(changes, hasLength(1));
  });

  testWidgets('cancelling the dialog applies the pending toolbar search only', (
    tester,
  ) async {
    final changes = <CharacterFilter>[];
    await mount(
      tester,
      changes,
      initial: const CharacterFilter(status: 'alive'),
    );
    await tester.enterText(find.byType(TextField), 'Rick');
    await tester.tap(find.byTooltip('Charaktere filtern'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
    await tester.enterText(dialogSearch, 'Discard this');
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(changes.single.name, 'Rick');
    expect(changes.single.status, 'alive');
    await tester.pump(const Duration(seconds: 1));
    expect(changes, hasLength(1));
  });

  testWidgets('cancelling without a pending search does not apply filters', (
    tester,
  ) async {
    final changes = <CharacterFilter>[];
    await mount(tester, changes);
    await tester.tap(find.byTooltip('Charaktere filtern'));
    await tester.pumpAndSettle();
    await tester.enterText(dialogSearch, 'Discard this');
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(changes, isEmpty);
  });

  for (final desktop in [false, true]) {
    testWidgets(
      'reset clears all filters and cancels pending search (desktop: $desktop)',
      (tester) async {
        final changes = <CharacterFilter>[];
        await mount(
          tester,
          changes,
          desktop: desktop,
          initial: const CharacterFilter(name: 'Rick', status: 'alive'),
        );
        await tester.enterText(find.byType(TextField), 'Morty');
        await tester.tap(
          desktop
              ? find.text('Zurücksetzen')
              : find.byTooltip('Filter zurücksetzen'),
        );
        await tester.pumpAndSettle();
        expect(changes.single.isActive, isFalse);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          '',
        );
        await tester.pump(const Duration(seconds: 1));
        expect(changes, hasLength(1));
      },
    );
  }

  testWidgets('disposing cancels a pending debounce', (tester) async {
    final changes = <CharacterFilter>[];
    await mount(tester, changes);
    await tester.enterText(find.byType(TextField), 'Rick');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(changes, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
