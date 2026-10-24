import 'character.dart';

class CharacterPage {
  final List<Character> characters;
  final bool hasNextPage;

  const CharacterPage({required this.characters, required this.hasNextPage});

  factory CharacterPage.fromJson(Map<String, dynamic> json) {
    final results = json['results'] as List<dynamic>;
    final info = json['info'] as Map<String, dynamic>;

    return CharacterPage(
      characters: results.map((item) {
        return Character.fromJson(item as Map<String, dynamic>);
      }).toList(),
      hasNextPage: info['next'] != null,
    );
  }
}
