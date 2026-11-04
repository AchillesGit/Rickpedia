import 'dart:async';

import 'package:flutter/material.dart';

import '../models/character_filter.dart';
import 'character_filter_dialog.dart';
import 'character_filter_fields.dart';

class CharacterToolbar extends StatefulWidget {
  final CharacterFilter filter;
  final bool desktop;
  final ValueChanged<CharacterFilter> onChanged;

  const CharacterToolbar({
    super.key,
    required this.filter,
    required this.desktop,
    required this.onChanged,
  });

  @override
  State<CharacterToolbar> createState() => _CharacterToolbarState();
}

class _CharacterToolbarState extends State<CharacterToolbar> {
  late final _name = TextEditingController(text: widget.filter.name);
  Timer? _debounce;

  @override
  void didUpdateWidget(covariant CharacterToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.filter, widget.filter)) {
      _debounce?.cancel();
      _setName(widget.filter.name);
    }
  }

  void _setName(String name) {
    _name.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
  }

  void _applyFilter(CharacterFilter filter) {
    _debounce?.cancel();
    _setName(filter.name);
    widget.onChanged(filter);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _name.dispose();
    super.dispose();
  }

  CharacterFilter _withName(CharacterFilter filter) => CharacterFilter(
    name: _name.text.trim(),
    status: filter.status,
    species: filter.species,
    gender: filter.gender,
  );

  Future<void> _showFilters() async {
    _debounce?.cancel();
    final filter = await showDialog<CharacterFilter>(
      context: context,
      builder: (_) => CharacterFilterDialog(filter: _withName(widget.filter)),
    );
    if (!mounted) return;
    if (filter != null) {
      _applyFilter(filter);
    } else if (_name.text.trim() != widget.filter.name) {
      _applyFilter(_withName(widget.filter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = widget.desktop;
    final search = TextField(
      controller: _name,
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'Charaktere suchen',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (_) {
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 350),
          () => _applyFilter(_withName(widget.filter)),
        );
      },
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(flex: desktop ? 2 : 1, child: search),
            const SizedBox(width: 12),
            if (desktop) ...[
              Expanded(
                flex: 4,
                child: CharacterFilterFields(
                  filter: widget.filter,
                  horizontal: true,
                  onChanged: (filter) => _applyFilter(_withName(filter)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _applyFilter(const CharacterFilter()),
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Zurücksetzen'),
              ),
            ] else ...[
              IconButton(
                tooltip: 'Charaktere filtern',
                onPressed: _showFilters,
                icon: Badge(
                  isLabelVisible: widget.filter.isActive,
                  child: const Icon(Icons.filter_alt_outlined),
                ),
              ),
              if (widget.filter.isActive)
                IconButton(
                  tooltip: 'Filter zurücksetzen',
                  onPressed: () => _applyFilter(const CharacterFilter()),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
