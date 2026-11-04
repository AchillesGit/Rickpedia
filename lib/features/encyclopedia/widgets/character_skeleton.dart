import 'package:flutter/material.dart';

/// Static placeholders avoid running a separate shimmer animation per card.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.width, required this.height});
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
