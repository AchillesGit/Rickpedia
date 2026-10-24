import 'package:flutter/material.dart';

/// Shared image presentation for the list and detail page.
class CharacterImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CharacterImage({super.key, required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => SizedBox.square(
          dimension: size,
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                semanticLabel: 'Bild nicht verfügbar',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
