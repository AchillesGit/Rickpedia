import 'package:flutter/material.dart';

class CharacterFeedback extends StatelessWidget {
  final bool loading;
  final bool failed;
  final bool isEmpty;
  final bool hasActiveFilter;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const CharacterFeedback({
    super.key,
    required this.loading,
    required this.failed,
    required this.isEmpty,
    required this.hasActiveFilter,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (failed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEmpty
                  ? 'Charaktere konnten nicht geladen werden.'
                  : 'Weitere Charaktere konnten nicht geladen werden.',
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }
    if (isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Keine Charaktere gefunden.'),
          if (hasActiveFilter)
            TextButton(
              onPressed: onReset,
              child: const Text('Filter zurücksetzen'),
            ),
        ],
      );
    }
    return const SizedBox(height: 24);
  }
}
