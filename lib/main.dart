import 'package:flutter/material.dart';

import 'features/characters/screens/character_screen.dart';

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
      debugShowCheckedModeBanner: false,
    );
  }
}
