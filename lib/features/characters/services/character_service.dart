import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/character.dart';

Future<List<Character>> fetchCharacters() async {
  final url = Uri.parse('https://rickandmortyapi.com/api/character');

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Failed to load characters');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  final results = data['results'] as List<dynamic>;

  return results.map((item) {
    return Character.fromJson(item as Map<String, dynamic>);
  }).toList();
}
