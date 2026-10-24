import 'package:flutter/material.dart';

import 'features/characters/widgets/character_card.dart';
import 'features/characters/models/character.dart';

const List<Character> demoCharacters = [
  Character(
    id: 1,
    name: 'Rick Sanchez',
    status: 'Alive',
    species: 'Human',
    imageUrl: 'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
  ),
  Character(
    id: 2,
    name: 'Morty Smith',
    status: 'Alive',
    species: 'Human',
    imageUrl: 'https://rickandmortyapi.com/api/character/avatar/2.jpeg',
  ),
  Character(
    id: 3,
    name: 'Summer Smith',
    status: 'Alive',
    species: 'Human',
    imageUrl: 'https://rickandmortyapi.com/api/character/avatar/3.jpeg',
  ),
  Character(
    id: 4,
    name: 'Beth Smith',
    status: 'Alive',
    species: 'Human',
    imageUrl: 'https://rickandmortyapi.com/api/character/avatar/4.jpeg',
  ),
];

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

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoCharacters.length,
        itemBuilder: (context, index) {
          final character = demoCharacters[index];

          return CharacterCard(character: character);
        },
      ),
    );
  }
}
