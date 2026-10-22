import 'package:flutter/material.dart';

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

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Image.network(
                  'https://rickandmortyapi.com/api/character/avatar/1.jpeg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 24),
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rick Sanchez',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Alive · Human'),
                    Text('Earth (C-137)'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
