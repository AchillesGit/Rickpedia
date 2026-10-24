import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character_page.dart';
import '../models/character_filter.dart';

Future<CharacterPage> fetchCharacters({
  int page = 1,
  CharacterFilter filter = const CharacterFilter(),
}) async {
  if (page < 1) throw ArgumentError.value(page, 'page', 'Must be positive');
  final url = Uri.https('rickandmortyapi.com', '/api/character', {
    'page': '$page',
    ...filter.toQueryParameters(),
  });

  final response = await http.get(url).timeout(const Duration(seconds: 15));

  // The API returns 404 when no characters match the query.
  if (response.statusCode == 404) {
    return const CharacterPage(characters: [], hasNextPage: false);
  }

  if (response.statusCode != 200) {
    throw Exception('Failed to load characters');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  return CharacterPage.fromJson(data);
}
