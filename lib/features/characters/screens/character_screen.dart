import 'package:flutter/material.dart';

import '../models/character_page.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  int _currentPage = 1;
  late Future<CharacterPage> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = fetchCharacters(page: _currentPage);
  }

  void _loadPage(int page) {
    setState(() {
      _currentPage = page;
      _charactersFuture = fetchCharacters(page: page);
    });
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
      body: FutureBuilder<CharacterPage>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Oops! Characters could not be loaded.'),
                  TextButton(
                    onPressed: () => _loadPage(_currentPage),
                    child: const Text('Try again'),
                  ),
                  if (_currentPage > 1)
                    TextButton(
                      onPressed: () => _loadPage(_currentPage - 1),
                      child: const Text('Zurück'),
                    ),
                ],
              ),
            );
          }

          final page = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: page.characters.isEmpty
                    ? const Center(child: Text('No characters found.'))
                    : ListView.builder(
                        key: ValueKey(_currentPage),
                        padding: const EdgeInsets.all(16),
                        itemCount: page.characters.length,
                        itemBuilder: (context, index) {
                          return CharacterCard(
                            character: page.characters[index],
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentPage > 1
                            ? () => _loadPage(_currentPage - 1)
                            : null,
                        child: const Text('Zurück'),
                      ),
                      Text('Seite $_currentPage'),
                      TextButton(
                        onPressed: page.hasNextPage
                            ? () => _loadPage(_currentPage + 1)
                            : null,
                        child: const Text('Weiter'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
