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
    final information = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(character.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final detail in details.entries)
                ListTile(
                  title: Text(detail.key),
                  subtitle: Text(
                    detail.value.trim().isEmpty || detail.value == 'unknown'
                        ? 'Unbekannt'
                        : detail.value,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) {
            final desktop = viewport.maxWidth >= 1000;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: desktop ? 1200 : 600),
                  child: desktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CharacterImage(
                              imageUrl: character.imageUrl,
                              size: 360,
                            ),
                            const SizedBox(width: 32),
                            Expanded(child: information),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) => Center(
                                child: CharacterImage(
                                  imageUrl: character.imageUrl,
                                  size: constraints.maxWidth
                                      .clamp(0, 400)
                                      .toDouble(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            information,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
