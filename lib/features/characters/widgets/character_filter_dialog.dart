import 'package:flutter/material.dart';

import '../models/character_filter.dart';

class CharacterFilterDialog extends StatefulWidget {
  final CharacterFilter filter;

  const CharacterFilterDialog({super.key, required this.filter});

  @override
  State<CharacterFilterDialog> createState() => _CharacterFilterDialogState();
}

class _CharacterFilterDialogState extends State<CharacterFilterDialog> {
  late final _name = TextEditingController(text: widget.filter.name);
  late final _species = TextEditingController(text: widget.filter.species);
  late final _type = TextEditingController(text: widget.filter.type);
  late String? _status = widget.filter.status;
  late String? _gender = widget.filter.gender;

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _type.dispose();
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
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Alle')),
                  DropdownMenuItem(value: 'alive', child: Text('Lebendig')),
                  DropdownMenuItem(value: 'dead', child: Text('Tot')),
                  DropdownMenuItem(value: 'unknown', child: Text('Unbekannt')),
                ],
                onChanged: (value) => _status = value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _species,
                decoration: const InputDecoration(labelText: 'Spezies'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Typ'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Geschlecht'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Alle')),
                  DropdownMenuItem(value: 'female', child: Text('Weiblich')),
                  DropdownMenuItem(value: 'male', child: Text('Männlich')),
                  DropdownMenuItem(
                    value: 'genderless',
                    child: Text('Geschlechtslos'),
                  ),
                  DropdownMenuItem(value: 'unknown', child: Text('Unbekannt')),
                ],
                onChanged: (value) => _gender = value,
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
              status: _status,
              species: _species.text.trim(),
              type: _type.text.trim(),
              gender: _gender,
            ),
          ),
          child: const Text('Anwenden'),
        ),
      ],
    );
  }
}
