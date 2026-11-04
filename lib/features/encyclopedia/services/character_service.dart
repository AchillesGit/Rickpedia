import '../../../core/network/rick_and_morty_api.dart';

import '../models/character_page.dart';
import '../models/character_filter.dart';

Future<CharacterPage> fetchCharacters({
  int page = 1,
  CharacterFilter filter = const CharacterFilter(),
}) async {
  if (page < 1) throw ArgumentError.value(page, 'page', 'Must be positive');
  try {
    final data = await fetchApiJson(
      'character',
      queryParameters: {'page': '$page', ...filter.toQueryParameters()},
    );
    return CharacterPage.fromJson(data as Map<String, dynamic>);
  } on ApiException catch (error) {
    // The API returns 404 when no characters match the query.
    if (error.statusCode == 404) {
      return const CharacterPage(characters: [], hasNextPage: false);
    }
    rethrow;
  }
}
