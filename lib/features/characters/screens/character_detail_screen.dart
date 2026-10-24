import 'package:flutter/material.dart';

import '../models/character.dart';
import '../widgets/character_image.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final details = <String, String>{
      'Status': character.status,
      'Spezies': character.species,
      if (character.type.trim().isNotEmpty) 'Typ': character.type,
      'Geschlecht': character.gender,
      'Herkunft': character.origin,
      'Letzter bekannter Aufenthaltsort': character.location,
      'Episodenauftritte': '${character.episodeCount}',
    };

    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => Center(
                      child: CharacterImage(
                        imageUrl: character.imageUrl,
                        size: constraints.maxWidth.clamp(0, 400).toDouble(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    character.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        for (final detail in details.entries)
                          ListTile(
                            title: Text(detail.key),
                            subtitle: Text(
                              detail.value.trim().isEmpty ||
                                      detail.value == 'unknown'
                                  ? 'Unbekannt'
                                  : detail.value,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
