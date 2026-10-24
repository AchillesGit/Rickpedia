import 'package:flutter/material.dart';

import '../models/character.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  late final Future<List<Character>> _charactersFuture;

  @override
  void initState() {
    super.initState();

    _charactersFuture = fetchCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/portal.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Text('Rickpedia'),
          ],
        ),
      ),
      body: FutureBuilder<List<Character>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return const Center(
              child: Text('Oops! Characters could not be loaded.'),
            );
          }

          // 3. Empty
          final characters = snapshot.data;

          if (characters == null || characters.isEmpty) {
            return const Center(child: Text('No characters found.'));
          }

          // 4. Success
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return CharacterCard(character: character);
            },
          );
        },
      ),
    );
  }
}
