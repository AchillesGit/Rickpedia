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
  late String _species = widget.filter.species;
  late String? _status = widget.filter.status;
  late String? _gender = widget.filter.gender;

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
              DropdownButtonFormField<String>(
                initialValue: _species,
                decoration: const InputDecoration(labelText: 'Spezies'),
                items: const [
                  DropdownMenuItem(value: '', child: Text('Alle')),
                  DropdownMenuItem(value: 'Human', child: Text('Human')),
                  DropdownMenuItem(value: 'Alien', child: Text('Alien')),
                  DropdownMenuItem(value: 'Humanoid', child: Text('Humanoid')),
                  DropdownMenuItem(value: 'Animal', child: Text('Animal')),
                  DropdownMenuItem(value: 'Robot', child: Text('Robot')),
                  DropdownMenuItem(value: 'unknown', child: Text('Unbekannt')),
                ],
                onChanged: (value) => _species = value ?? '',
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
              species: _species,
              gender: _gender,
            ),
          ),
          child: const Text('Anwenden'),
        ),
      ],
    );
  }
}
