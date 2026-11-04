import 'package:flutter/material.dart';

import '../models/character_filter.dart';
import 'character_filter_fields.dart';

class CharacterFilterDialog extends StatefulWidget {
  final CharacterFilter filter;
  const CharacterFilterDialog({super.key, required this.filter});
  @override
  State<CharacterFilterDialog> createState() => _CharacterFilterDialogState();
}

class _CharacterFilterDialogState extends State<CharacterFilterDialog> {
  late final _name = TextEditingController(text: widget.filter.name);
  late CharacterFilter _filter = widget.filter;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Charaktere filtern'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              CharacterFilterFields(
                filter: _filter,
                onChanged: (filter) => setState(() => _filter = filter),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            CharacterFilter(
              name: _name.text.trim(),
              status: _filter.status,
              species: _filter.species,
              gender: _filter.gender,
            ),
          ),
          child: const Text('Anwenden'),
        ),
      ],
    );
  }
}
