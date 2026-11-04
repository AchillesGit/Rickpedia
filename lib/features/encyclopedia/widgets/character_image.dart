import 'dart:async';

import 'package:flutter/material.dart';

import 'character_skeleton.dart';

class CharacterImage extends StatefulWidget {
  final String imageUrl;
  final double size;

  const CharacterImage({super.key, required this.imageUrl, required this.size});

  @override
  State<CharacterImage> createState() => _CharacterImageState();
}

class _CharacterImageState extends State<CharacterImage> {
  Timer? _retry;
  bool _retried = false;

  @override
  void didUpdateWidget(CharacterImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retry?.cancel();
      _retry = null;
      _retried = false;
    }
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox.square(
      dimension: widget.size,
      child: Image.network(
        widget.imageUrl,
        key: ValueKey((widget.imageUrl, _retried)),
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        filterQuality: FilterQuality.low,
        frameBuilder: (_, child, frame, synchronous) =>
            frame != null || synchronous
            ? child
            : SkeletonBlock(height: widget.size, width: widget.size),
        errorBuilder: (_, error, stack) {
          if (!_retried) {
            _retry ??= Timer(const Duration(seconds: 1), () {
              setState(() => _retried = true);
            });
            return SkeletonBlock(height: widget.size, width: widget.size);
          }
          return ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                semanticLabel: 'Bild nicht verf\u00fcgbar',
              ),
            ),
          );
        },
      ),
    ),
  );
}
