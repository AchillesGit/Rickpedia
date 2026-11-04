import 'package:flutter/material.dart';

import '../models/character_filter.dart';

/// Shared choices for the desktop toolbar and compact filter dialog.
class CharacterFilterFields extends StatelessWidget {
  final CharacterFilter filter;
  final ValueChanged<CharacterFilter> onChanged;
  final bool horizontal;

  const CharacterFilterFields({
    super.key,
    required this.filter,
    required this.onChanged,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      _dropdown(
        'Status',
        filter.status ?? '',
        const {
          '': 'Alle',
          'alive': 'Lebendig',
          'dead': 'Tot',
          'unknown': 'Unbekannt',
        },
        (value) => onChanged(
          CharacterFilter(
            name: filter.name,
            status: value.isEmpty ? null : value,
            species: filter.species,
            gender: filter.gender,
          ),
        ),
      ),
      _dropdown(
        'Spezies',
        filter.species,
        const {
          '': 'Alle',
          'Human': 'Human',
          'Alien': 'Alien',
          'Humanoid': 'Humanoid',
          'Animal': 'Animal',
          'Robot': 'Robot',
          'unknown': 'Unbekannt',
        },
        (value) => onChanged(
          CharacterFilter(
            name: filter.name,
            status: filter.status,
            species: value,
            gender: filter.gender,
          ),
        ),
      ),
      _dropdown(
        'Geschlecht',
        filter.gender ?? '',
        const {
          '': 'Alle',
          'female': 'Weiblich',
          'male': 'Männlich',
          'genderless': 'Geschlechtslos',
          'unknown': 'Unbekannt',
        },
        (value) => onChanged(
          CharacterFilter(
            name: filter.name,
            status: filter.status,
            species: filter.species,
            gender: value.isEmpty ? null : value,
          ),
        ),
      ),
    ];
    if (horizontal) {
      return Row(
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: fields[i]),
          ],
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fields.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          fields[i],
        ],
      ],
    );
  }

  Widget _dropdown(
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: options.entries
          .map(
            (entry) =>
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          )
          .toList(),
      onChanged: (value) => onChanged(value ?? ''),
    );
  }
}
