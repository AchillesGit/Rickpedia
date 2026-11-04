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
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF91CD68),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF141817),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const CharacterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
