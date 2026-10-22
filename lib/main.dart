import 'package:flutter/material.dart';

import 'features/characters/widgets/character_card.dart';

void main() {
  runApp(const RickpediaApp());
}

class RickpediaApp extends StatelessWidget {
  const RickpediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rickpedia',
      theme: ThemeData.dark(),
      home: const CharacterScreen(),
    );
  }
}

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

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

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CharacterCard(
            name: 'Rick Sanchez',
            status: 'Alive · Human',
            imageUrl: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
          ),
          CharacterCard(
            name: 'Morty Smith',
            status: 'Alive · Human',
            imageUrl: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
          ),
          CharacterCard(
            name: 'Summer Smith',
            status: 'Alive · Human',
            imageUrl: 'https://rickandmortyapi.com/api/character/avatar/3.jpeg',
          ),
        ],
      ),
    );
  }
}
