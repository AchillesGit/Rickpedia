import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character_page.dart';

Future<CharacterPage> fetchCharacters({int page = 1}) async {
  final url = Uri.https('rickandmortyapi.com', '/api/character', {
    'page': '$page',
  });

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load characters');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  return CharacterPage.fromJson(data);
}
