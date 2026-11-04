import 'package:flutter/material.dart';

class DetailLoadError extends StatelessWidget {
  final VoidCallback onRetry;
  const DetailLoadError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Daten konnten nicht geladen werden.'),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Erneut versuchen')),
      ],
    ),
  );
}
