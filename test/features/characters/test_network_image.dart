import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Seed Flutter's own cache so screen tests do not make image requests.
Future<void> cacheNetworkImage(String url) async {
  final codec = await ui.instantiateImageCodec(
    File('assets/images/portal.png').readAsBytesSync(),
  );
  final frame = await codec.getNextFrame();
  codec.dispose();
  PaintingBinding.instance.imageCache.putIfAbsent(
    NetworkImage(url),
    () => OneFrameImageStreamCompleter(
      Future.value(ImageInfo(image: frame.image)),
    ),
  );
}
