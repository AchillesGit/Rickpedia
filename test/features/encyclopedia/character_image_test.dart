import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rickpedia/features/encyclopedia/widgets/character_image.dart';
import 'package:rickpedia/features/encyclopedia/widgets/character_skeleton.dart';

import 'test_network_image.dart';

const url = 'https://example.com/retry.png';

Completer<ImageInfo> pendingImage() {
  final result = Completer<ImageInfo>();
  // Match NetworkImage, which evicts failed requests from Flutter's cache.
  final image = result.future.catchError((Object error, StackTrace stack) {
    PaintingBinding.instance.imageCache.evict(const NetworkImage(url));
    Error.throwWithStackTrace(error, stack);
  });
  PaintingBinding.instance.imageCache.putIfAbsent(
    const NetworkImage(url),
    () => OneFrameImageStreamCompleter(image),
  );
  return result;
}

Future<void> mount(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(home: CharacterImage(imageUrl: url, size: 100)),
);

void main() {
  setUp(() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  });
  testWidgets('retries a failed image after one second and displays it', (
    tester,
  ) async {
    final first = pendingImage();
    await mount(tester);
    expect(find.byType(SkeletonBlock), findsOneWidget);
    final originalKey = tester.widget<Image>(find.byType(Image)).key;
    first.completeError(Exception('Image unavailable'));
    await tester.pump();
    await tester.runAsync(() => cacheNetworkImage(url));
    await tester.pump(const Duration(milliseconds: 999));
    expect(tester.widget<Image>(find.byType(Image)).key, originalKey);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(tester.widget<Image>(find.byType(Image)).key, isNot(originalKey));
    expect(find.byType(SkeletonBlock), findsNothing);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
  });

  testWidgets('shows a fallback if the retry also fails', (tester) async {
    final first = pendingImage();
    await mount(tester);
    first.completeError(Exception('Image unavailable'));
    await tester.pump();
    final second = pendingImage();
    await tester.pump(const Duration(seconds: 1));
    second.completeError(Exception('Still unavailable'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('disposal cancels the pending retry', (tester) async {
    final first = pendingImage();
    await mount(tester);
    first.completeError(Exception('Image unavailable'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
